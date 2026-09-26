import SwiftUI

/// Today's progress over the deck: a single card on the cover, an open book on the inner display.
struct StudyView: View {
  @Environment(StudySession.self) private var session
  @Environment(\.cardStyle) private var style
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        DailyProgressHeader(known: session.knownCount, total: session.deck.count)
        if let card = session.current {
          if horizontalSizeClass == .regular {
            SpreadView(card: card)
          } else {
            CoverDeck()
          }
        } else {
          DeckCompleteContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
              PaperSurface()
            }
            .transition(.blurReplace)
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 6)
      .padding(.bottom, 16)
      .background(style.canvas)
      .toolbar {
        ToolbarItem {
          Toggle(isOn: isCurrentStarred) {
            Label("Review Again", systemImage: isCurrentStarred.wrappedValue ? "star.fill" : "star")
          }
          .toggleStyle(.button)
          .disabled(session.current == nil)
        }
      }
      .toolbarTitleDisplayMode(.inline)
      .sensoryFeedback(.impact(weight: .light), trigger: session.revealCount)
      .sensoryFeedback(.selection, trigger: isCurrentStarred.wrappedValue)
    }
    .tint(style.accent)
  }

  /// The ★ in the vertical bar: a starred card goes back into the deck instead of counting as known.
  private var isCurrentStarred: Binding<Bool> {
    Binding {
      session.current.map { session.isStarred($0.word) } ?? false
    } set: { _ in
      if let word = session.current?.word {
        session.toggleStar(word)
      }
    }
  }
}
