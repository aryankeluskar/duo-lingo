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
    You make flashcards for active recall from one web page. The front of each card is shown \
    on a small cover display; the reader says the answer out loud, then unfolds the phone to \
    check it. Pick the 12 to 16 ideas on the page most worth remembering, most important first.

    If the page teaches a language, make vocabulary cards: term is the word in that language, \
    note is its part of speech, meaning is the English, example is a short sentence in that \
    language, exampleTranslation is its English, and language is that language's BCP 47 code.

    Otherwise, language is "en" and:
    - term: the cue, a name, term, or concept, at most 32 characters. Never a question.
    - note: the field or section it comes from, 1 to 3 lowercase words.
    - meaning: the answer, at most 60 characters, crisp and specific, no trailing period.
    - example: one concrete sentence from the page that uses or illustrates it, at most 110 characters.
    - exampleTranslation: one sentence on why it matters or how to tell it apart from a near miss, at most 110 characters.

    Every card must be true to the page. No duplicates. title is a short deck name, at most 22 characters.
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
