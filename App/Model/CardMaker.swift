import Foundation

/// Turns any page on the web into a deck: reads the page, then asks OpenAI for the handful of
/// ideas on it worth remembering, each written as a card to recall before you unfold.
enum CardMaker {
  enum Failure: LocalizedError {
    case missingKey
    case unreadablePage
    case noCards(String)

    var errorDescription: String? {
      switch self {
      case .missingKey: "Add an OpenAI API key first."
      case .unreadablePage: "Couldn't read that page."
      case .noCards(let reason): reason
      }
    }
  }

  static var apiKey: String? {
    get { UserDefaults.standard.string(forKey: "openAIKey").flatMap { $0.isEmpty ? nil : $0 } }
    set { UserDefaults.standard.set(newValue, forKey: "openAIKey") }
  }

  /// Keeps a key passed at launch, so the app still has it when it's opened from the Home Screen.
  static func keepLaunchKey() {
    if let key = apiKey {
      apiKey = key
    }
  }

  static func makeDeck(from url: URL) async throws -> WebDeck.Contents {
    guard let key = apiKey else { throw Failure.missingKey }
    let page = try await readPage(url)
    return try await writeCards(from: page, source: url, key: key)
  }

  // MARK: - Reading the page

  private static func readPage(_ url: URL) async throws -> String {
    var request = URLRequest(url: url, timeoutInterval: 20)
    request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
    let (data, _) = try await URLSession.shared.data(for: request)
    guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
      throw Failure.unreadablePage
    }
    let text = plainText(html)
    guard text.count > 200 else { throw Failure.unreadablePage }
    return String(text.prefix(24_000))
  }

  /// The words a reader would see: scripts, styles and tags gone, entities decoded, space collapsed.
  private static func plainText(_ html: String) -> String {
    var text = html
    for pattern in ["(?is)<(script|style|noscript|svg|head|nav|footer)[^>]*>.*?</\\1>", "(?s)<!--.*?-->"] {
      text = text.replacingOccurrences(of: pattern, with: " ", options: .regularExpression)
    }
    text = text.replacingOccurrences(of: "(?i)<(br|/p|/div|/li|/h[1-6]|/tr)[^>]*>", with: "\n", options: .regularExpression)
    text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
    for (entity, character) in ["&nbsp;": " ", "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": "\"", "&#39;": "'", "&#x27;": "'", "&rsquo;": "’", "&ldquo;": "“", "&rdquo;": "”", "&mdash;": "—", "&ndash;": "–"] {
      text = text.replacingOccurrences(of: entity, with: character)
    }
    text = text.replacingOccurrences(of: "[ \\t]+", with: " ", options: .regularExpression)
    text = text.replacingOccurrences(of: "\\s*\\n\\s*", with: "\n", options: .regularExpression)
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  // MARK: - Writing the cards

  private static let instructions = """
    You write flashcards that test what someone just read. Each card is one short question \
    and its short answer: a fact worth memorizing from the page. The question is shown on a \
    small cover display; the reader answers out loud, then unfolds the phone to check.

    Write 10 to 15 cards, most important first. Test specific, checkable facts: numbers, \
    names, dates, definitions, claims, causes, steps, comparisons. One fact per card. Every \
    answer must be stated on the page. No duplicates, no vague themes, no opinions. Good \
    cards look like "What year did Abbott publish on recall?" → "1909", or "How long can \
    you do hard work per day, per Graham?" → "About 4 hours".

    - term: the question, at most 60 characters, ending with "?". A stranger who never saw \
      the page must know exactly what is asked, so always name the subject. Write "Who ran \
      the first testing effect study?", not "Who published the first studies?". Never say \
      "the author", "this article", "it" or "they".
    - meaning: the answer, 1 to 6 words, at most 40 characters. A fact, not a sentence. No \
      trailing period.
    - note: the topic, 1 or 2 lowercase words.
    - example: one sentence from the page, lightly trimmed, that states the answer, at most \
      100 characters.
    - exampleTranslation: a short hook that makes it stick (a contrast, a cause, or a \
      mnemonic), at most 80 characters.
    - language: "en".

    Exception: if the page teaches a language's vocabulary, make vocabulary cards instead. \
    term is the word in that language (no question mark), note its part of speech, meaning \
    the English, example a short sentence in that language, exampleTranslation its English, \
    and language that language's BCP 47 code.

    title is a short deck name, at most 22 characters.
    """

  private static let schema: [String: Any] = [
    "type": "object",
    "properties": [
      "title": ["type": "string"],
      "language": ["type": "string"],
      "cards": [
        "type": "array",
        "items": [
          "type": "object",
          "properties": [
            "term": ["type": "string"],
            "note": ["type": "string"],
            "meaning": ["type": "string"],
            "example": ["type": "string"],
            "exampleTranslation": ["type": "string"],
          ],
          "required": ["term", "note", "meaning", "example", "exampleTranslation"],
          "additionalProperties": false,
        ],
      ],
    ],
    "required": ["title", "language", "cards"],
    "additionalProperties": false,
  ]

  private struct Response: Decodable {
    struct Item: Decodable {
      struct Content: Decodable {
        var type: String
        var text: String?
        var refusal: String?
      }
      var type: String
      var content: [Content]?
    }
    struct Failure: Decodable { var message: String }
    var output: [Item]?
    var error: Failure?
  }

  private struct Generated: Decodable {
    var title: String
    var language: String
    var cards: [WebDeck.Card]
  }

  private static func writeCards(from page: String, source: URL, key: String) async throws -> WebDeck.Contents {
    var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!, timeoutInterval: 90)
    request.httpMethod = "POST"
    request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: [String: Any] = [
      "model": "gpt-5.4-mini",
      "reasoning": ["effort": "low"],
      "instructions": instructions,
      "input": "Page: \(source.absoluteString)\n\n\(page)",
      "text": ["format": ["type": "json_schema", "name": "deck", "strict": true, "schema": schema]],
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(Response.self, from: data)
    if let error = response.error {
      throw Failure.noCards(error.message)
    }
    let content = response.output?.first { $0.type == "message" }?.content?.first
    if let refusal = content?.refusal {
      throw Failure.noCards(refusal)
    }
    guard let text = content?.text, let json = text.data(using: .utf8) else {
      throw Failure.noCards("No cards came back. Try another link.")
    }
    let generated = try JSONDecoder().decode(Generated.self, from: json)
    var seen = Set<String>()
    let cards = generated.cards.filter { seen.insert($0.term).inserted }
    guard !cards.isEmpty else { throw Failure.noCards("No cards came back. Try another link.") }
    return WebDeck.Contents(title: generated.title, language: generated.language, source: source.absoluteString, cards: cards)
  }
}
