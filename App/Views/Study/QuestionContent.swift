import SwiftUI

/// The word, set large with plenty of air, and the language beneath it.
struct QuestionContent: View {
  var word: Word

  @Environment(\.cardStyle) private var style
  @ScaledMetric(relativeTo: .largeTitle) private var wordSize = 58
  @ScaledMetric(relativeTo: .subheadline) private var captionSize = 15

  var body: some View {
    VStack(spacing: 14) {
      Text(word.spokenTerm)
        .font(style.word.font(size: wordSize))
        .foregroundStyle(style.ink)
        .typesettingLanguage(.init(identifier: "ja"))
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.5)
      Text("Japanese")
        .font(style.caption.font(size: captionSize))
        .foregroundStyle(style.inkSecondary)
    }
    .padding(28)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .accessibilityElement(children: .combine)
  }
}
