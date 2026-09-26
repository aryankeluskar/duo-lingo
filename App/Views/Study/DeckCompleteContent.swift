import SwiftUI

/// Shown once every card in the deck is known for today.
struct DeckCompleteContent: View {
  @Environment(StudySession.self) private var session
  @Environment(\.cardStyle) private var style
  @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 34
  @ScaledMetric(relativeTo: .body) private var bodySize = 17

  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 52))
        .foregroundStyle(style.accent)
        .symbolEffect(.bounce, value: session.knownCount)
        .padding(.bottom, 4)
        .accessibilityHidden(true)
      Text("All \(session.words.count) words, done")
        .font(.system(size: titleSize, weight: style.wordWeight, design: style.wordDesign))
        .foregroundStyle(style.ink)
      Text("Come back tomorrow, or go through the deck again.")
        .font(.system(size: bodySize))
        .foregroundStyle(style.inkSecondary)
      Group {
        if style.surface == .paper {
          studyAgain.buttonStyle(.borderedProminent)
        } else {
          studyAgain.buttonStyle(.glass)
        }
      }
      .controlSize(.large)
      .padding(.top, 12)
    }
    .multilineTextAlignment(.center)
    .padding(32)
  }

  private var studyAgain: some View {
    Button("Study Again", systemImage: "arrow.counterclockwise") {
      withAnimation(.smooth) {
        session.startOver()
      }
    }
  }
}
