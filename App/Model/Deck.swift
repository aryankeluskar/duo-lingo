import Foundation

/// A language to study, with its words.
enum Deck: String, CaseIterable, Identifiable {
  case spanish
  case japanese

  var id: Self { self }

  var words: [Word] {
    switch self {
    case .spanish: Word.spanish
    case .japanese: Word.japanese
    }
  }

  /// The language, for VoiceOver and typesetting.
  var language: Locale.Language {
    Locale.Language(identifier: languageCode)
  }

  /// The language's name in English, shown under the word.
  var name: LocalizedStringResource {
    switch self {
    case .spanish: "Spanish"
    case .japanese: "Japanese"
    }
  }

  /// The language's name in itself, tagged so VoiceOver pronounces it.
  var nativeName: AttributedString {
    switch self {
    case .spanish: tagged("Español")
    case .japanese: tagged("日本語")
    }
  }

  /// Whether the script sits below the Latin baseline, as kanji and kana do.
  var usesIdeographs: Bool {
    self == .japanese
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
    }
  }
}
