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
        // Kanji sit about 0.08 em below the Latin baseline, kana a little less. Lining up the
        // bottoms of the glyphs, not the baselines, makes the word and its meaning read as one line.
        .alignmentGuide(.horizon) { $0[.lastTextBaseline] + wordSize * 0.07 }
      Text("Japanese")
        .font(style.caption.font(size: captionSize))
        .foregroundStyle(style.inkSecondary)
    }
    .padding(28)
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
  }
}
