import Foundation
import Observation

/// The deck made from a link: whatever page you pasted, turned into cards. It keeps the most
/// recent one, saved so it's still there tomorrow.
@Observable
final class WebDeck {
  static let shared = WebDeck()

  struct Contents: Codable {
    var title: String
    var language: String
    var source: String
    var cards: [Card]
  }

  struct Card: Codable {
    var term: String
    var note: String
    var meaning: String
    var example: String
    var exampleTranslation: String
  }

  private(set) var contents: Contents?

  private init() {
    if let data = UserDefaults.standard.data(forKey: Self.key) {
      contents = try? JSONDecoder().decode(Contents.self, from: data)
    }
  }

  var title: String { contents?.title ?? "From the Web" }
  var language: String { contents?.language ?? "en" }

  var words: [Word] {
    (contents?.cards ?? []).map {
      Word(deck: .web, term: $0.term, note: $0.note, meaning: $0.meaning, example: $0.example, exampleTranslation: $0.exampleTranslation)
    }
  }

  func replace(with newContents: Contents) {
    contents = newContents
    UserDefaults.standard.set(try? JSONEncoder().encode(newContents), forKey: Self.key)
  }

  private static let key = "webDeck"
}
