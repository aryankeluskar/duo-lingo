import Foundation

struct Word: Identifiable, Hashable {
  var deck: Deck
  var term: String
  /// A short note beside the term: the reading for Japanese, the part of speech (and a noun's
  /// gender) for Spanish.
  var note: String
  var meaning: String
  var example: String
  var exampleTranslation: String

  var id: String { term }

  /// The term tagged with its language, so VoiceOver reads it with the right voice.
  var spokenTerm: AttributedString { deck.tagged(term) }

  /// The note tagged with its language.
  var spokenNote: AttributedString { deck.tagged(note) }

  /// The example tagged with its language.
  var spokenExample: AttributedString { deck.tagged(example) }
}
