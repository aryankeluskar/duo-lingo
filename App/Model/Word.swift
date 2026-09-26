import Foundation

struct Word: Identifiable, Hashable {
  var term: String
  var reading: String
  var meaning: String
  var example: String
  var exampleTranslation: String

  var id: String { term }

  /// The term tagged as Japanese, so VoiceOver reads it with a Japanese voice.
  var spokenTerm: AttributedString { Self.japanese(term) }

  /// The example tagged as Japanese, so VoiceOver reads it with a Japanese voice.
  var spokenExample: AttributedString { Self.japanese(example) }

  private static func japanese(_ string: String) -> AttributedString {
    var text = AttributedString(string)
    text.languageIdentifier = "ja"
    return text
  }
}
