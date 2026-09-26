import Foundation

/// A deck to study: a language with its words, or a college subject with its core ideas.
enum Deck: String, CaseIterable, Identifiable {
  case spanish
  case japanese
  case biology
  case chemistry
  case physics
  case calculus
  case linearAlgebra
  case web

  /// The shelf a deck sits on in the picker.
  enum Subject: String, CaseIterable, Identifiable {
    case languages
    case sciences
    case mathematics
    case web

    var id: Self { self }

    var name: LocalizedStringResource {
      switch self {
      case .languages: "Languages"
      case .sciences: "Sciences"
      case .mathematics: "Mathematics"
      case .web: "From a Link"
      }
    }

    var decks: [Deck] {
      Deck.allCases.filter { $0.subject == self && !$0.words.isEmpty }
    }

    /// The shelves with something on them: the link shelf stays hidden until you make a deck.
    static var stocked: [Subject] {
      allCases.filter { !$0.decks.isEmpty }
    }
  }

  var id: Self { self }

  var subject: Subject {
    switch self {
    case .spanish, .japanese: .languages
    case .biology, .chemistry, .physics: .sciences
    case .calculus, .linearAlgebra: .mathematics
    case .web: .web
    }
  }

  var words: [Word] {
    switch self {
    case .spanish: Word.spanish
    case .japanese: Word.japanese
    case .biology: Word.biology
    case .chemistry: Word.chemistry
    case .physics: Word.physics
    case .calculus: Word.calculus
    case .linearAlgebra: Word.linearAlgebra
    case .web: WebDeck.shared.words
    }
  }

  /// The language, for VoiceOver and typesetting.
  var language: Locale.Language {
    Locale.Language(identifier: languageCode)
  }

  /// The deck's name in English: the language, or the subject.
  var name: LocalizedStringResource {
    switch self {
    case .spanish: "Spanish"
    case .japanese: "Japanese"
    case .biology: "Biology"
    case .chemistry: "Chemistry"
    case .physics: "Physics"
    case .calculus: "Calculus"
    case .linearAlgebra: "Linear Algebra"
    case .web: "\(WebDeck.shared.title)"
    }
  }

  /// The deck's name as it reads on its chip: a language in itself, tagged so VoiceOver
  /// pronounces it, and a subject in English.
  var nativeName: AttributedString {
    switch self {
    case .spanish: tagged("Español")
    case .japanese: tagged("日本語")
    default: AttributedString(localized: name)
    }
  }

  /// Whether the script sits below the Latin baseline, as kanji and kana do.
  var usesIdeographs: Bool {
    self == .japanese
  }

  /// Whether a card's front is a whole concept or formula that may need a second line.
  var hasLongTerms: Bool {
    subject != .languages
  }

  /// Tags text with the deck's language, so VoiceOver reads it with the right voice.
  func tagged(_ string: String) -> AttributedString {
    var text = AttributedString(string)
    text.languageIdentifier = languageCode
    return text
  }

  private var languageCode: String {
    switch self {
    case .spanish: "es"
    case .japanese: "ja"
    case .web: WebDeck.shared.language
    default: "en"
    }
  }
}
