import SwiftUI

/// Shown once every card in the deck is known for today.
struct DeckCompleteContent: View {
  @Environment(StudySession.self) private var session
  @Environment(\.cardStyle) private var style
  @ScaledMetric(relativeTo: .title) private var titleSize = 28
  @ScaledMetric(relativeTo: .subheadline) private var bodySize = 16

  var body: some View {
    VStack(spacing: 14) {
      Image(systemName: "checkmark.seal.fill")
        .font(.system(size: 44))
        .foregroundStyle(style.accent)
        .symbolEffect(.bounce, value: session.knownCount)
        .accessibilityHidden(true)
      Text("You know all \(session.deck.count) words")
        .font(style.meaning.font(size: titleSize))
        .foregroundStyle(style.ink)
      Text("Come back tomorrow, or go through the deck again.")
        .font(style.translation.font(size: bodySize))
        .foregroundStyle(style.inkSecondary)
      Button("Study Again", systemImage: "arrow.counterclockwise") {
        withAnimation(.smooth) {
          session.startOver()
        }
      }
      .buttonStyle(.bordered)
      .controlSize(.large)
      .padding(.top, 8)
    }
    .multilineTextAlignment(.center)
    .padding(32)
  }
}
