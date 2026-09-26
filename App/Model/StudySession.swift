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

  private(set) var deck: Deck
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
  #if DEBUG
  /// Set while a `-hingeAngle` pose stands in for the hinge. The pose holds only until the
  /// hinge really moves, so an app launched for a screenshot still folds and unfolds.
  private var isPosePinned = false
  private var pinnedHingePosture: FoldState.Posture?
  #endif

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    deck = defaults.string(forKey: Keys.deck).flatMap(Deck.init) ?? .spanish
    // Always today, so moving between displays (which reactivates the scene) never looks like a new day.
    knownDay = Self.today
    starred = Set(defaults.stringArray(forKey: Keys.starred) ?? [])
    if defaults.string(forKey: Keys.knownDay) == knownDay {
      known = Set(defaults.stringArray(forKey: Keys.known) ?? [])
    }
    rebuildQueue()
    #if DEBUG
    if defaults.bool(forKey: "revealOnLaunch") {
      reveal()
    }
    if let pose = FoldState.debugPose {
      fold = pose
      isPosePinned = true
    }
    #endif
  }

  var words: [Word] { deck.words }
  var current: Card? { queue.first }
  var isRevealed: Bool { phase == .revealed }
  var knownCount: Int { words.filter { known.contains($0.id) }.count }

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
    #if DEBUG
    if isPosePinned {
      // The first report is the hinge as it lay at launch; any other posture means it moved.
      guard let hinge = pinnedHingePosture else {
        pinnedHingePosture = state.posture
        return
      }
      if state.posture == hinge { return }
      isPosePinned = false
    }
    #endif
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

  /// Switches to another language and starts from its first card not yet known today.
  func selectDeck(_ newDeck: Deck) {
    guard newDeck != deck else { return }
    deck = newDeck
    defaults.set(newDeck.rawValue, forKey: Keys.deck)
    rebuildQueue()
  }

  /// Opens a deck just made from a link, from its first card, even if the last one was open.
  func studyWebDeck() {
    deck = .web
    defaults.set(Deck.web.rawValue, forKey: Keys.deck)
    rebuildQueue()
  }

  /// Goes through the current deck again from the start.
  func startOver() {
    known.subtract(words.map(\.id))
    saveKnown()
    rebuildQueue()
  }

  /// Starts a fresh day's count after midnight.
  func refreshDay() {
    guard knownDay != Self.today else { return }
    known = []
    saveKnown()
    rebuildQueue()
  }

  private func rebuildQueue() {
    queue = words.filter { !known.contains($0.id) }.map(makeCard)
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
    static let deck = "deck"
  }
}
