import Foundation
import Observation

/// One pass through the deck. On iPhone Duo the hinge drives it: unfolding reveals the
/// answer, and folding after a reveal puts the card away.
@MainActor
@Observable
final class StudySession {
  enum Phase: Equatable {
    case prompt
    case revealed
  }

  /// A word's place in the queue. A starred word that goes back into the deck gets a new card.
  struct Card: Identifiable, Equatable {
    var id: Int
    var word: Word
  }

  let deck: [Word]
  private(set) var queue: [Card] = []
  private(set) var phase = Phase.prompt
  private(set) var known: Set<String> = []
  private(set) var starred: Set<String> = []
  private(set) var fold = FoldState()
  /// Counts reveals, to trigger feedback.
  private(set) var revealCount = 0
  /// Set when the device folds on a revealed card. The cover deals the card away once it's on screen.
  private(set) var isDealPending = false

  private var nextCardID = 0
  private var knownDay: String
  private let defaults: UserDefaults

  init(deck: [Word] = Word.japanese, defaults: UserDefaults = .standard) {
    self.deck = deck
    self.defaults = defaults
    knownDay = defaults.string(forKey: Keys.knownDay) ?? ""
    starred = Set(defaults.stringArray(forKey: Keys.starred) ?? [])
    if knownDay == Self.today {
      known = Set(defaults.stringArray(forKey: Keys.known) ?? [])
    }
    rebuildQueue()
    #if DEBUG
    if defaults.bool(forKey: "revealOnLaunch") {
      reveal()
    }
    #endif
  }

  var current: Card? { queue.first }
  var isRevealed: Bool { phase == .revealed }
  var knownCount: Int { known.count }

  func isStarred(_ word: Word) -> Bool {
    starred.contains(word.id)
  }

  func toggleStar(_ word: Word) {
    if starred.contains(word.id) {
      starred.remove(word.id)
    } else {
      starred.insert(word.id)
    }
    defaults.set(Array(starred), forKey: Keys.starred)
  }

  func reveal() {
    guard current != nil, phase == .prompt else { return }
    phase = .revealed
    revealCount += 1
  }

  /// Puts the current card away. A starred card goes back into the deck a few cards later;
  /// any other card counts as known.
  func advance() {
    isDealPending = false
    guard !queue.isEmpty else { return }
    let card = queue.removeFirst()
    if starred.contains(card.word.id) {
      queue.insert(makeCard(for: card.word), at: min(3, queue.count))
    } else {
      known.insert(card.word.id)
      saveKnown()
    }
    phase = .prompt
  }

  func dealIfPending() {
    if isDealPending {
      advance()
    }
  }

  /// Reveals on unfold and puts the card away on fold, but only while the deck is on screen.
  func updateFold(_ state: FoldState, isStudying: Bool) {
    let previous = fold.posture
    fold = state
    guard isStudying, let posture = state.posture, let previous, posture != previous else { return }
    if posture == .closed {
      if phase == .revealed {
        isDealPending = true
      }
    } else if previous == .closed {
      dealIfPending()
      reveal()
    }
  }

  func startOver() {
    known = []
    saveKnown()
    rebuildQueue()
  }

  /// Starts a fresh day's count after midnight.
  func refreshDay() {
    guard knownDay != Self.today else { return }
    startOver()
  }

  private func rebuildQueue() {
    queue = deck.filter { !known.contains($0.id) }.map(makeCard)
    phase = .prompt
    isDealPending = false
  }

  private func makeCard(for word: Word) -> Card {
    defer { nextCardID += 1 }
    return Card(id: nextCardID, word: word)
  }

  private func saveKnown() {
    knownDay = Self.today
    defaults.set(Array(known), forKey: Keys.known)
    defaults.set(knownDay, forKey: Keys.knownDay)
  }

  private static var today: String {
    let day = Calendar.current.dateComponents([.year, .month, .day], from: .now)
    return "\(day.year ?? 0)-\(day.month ?? 0)-\(day.day ?? 0)"
  }

  private enum Keys {
    static let known = "knownWords"
    static let knownDay = "knownDay"
    static let starred = "starredWords"
  }
}
