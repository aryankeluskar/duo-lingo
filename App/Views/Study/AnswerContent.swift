import SwiftUI

/// The meaning, the example, and its translation, developed line by line.
struct AnswerContent: View {
  var word: Word
  var isRevealed: Bool
  /// Shows the term above the meaning, for a single card with no question page beside it.
  var showsTerm = false
  /// How far the device has opened, while the hinge is moving. The answer never develops
  /// further than the pages have come apart.
  var openingProgress: Double? = nil

  @Environment(\.cardStyle) private var style
  @ScaledMetric(relativeTo: .title2) private var termSize = 22
  @ScaledMetric(relativeTo: .largeTitle) private var meaningSize = 40
  @ScaledMetric(relativeTo: .title3) private var exampleSize = 20
  @ScaledMetric(relativeTo: .body) private var translationSize = 17
  @State private var timedProgress = 0.0

  private var progress: Double {
    isRevealed ? min(timedProgress, openingProgress ?? 1) : 0
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if showsTerm {
        Text(word.spokenTerm)
          .font(.system(size: termSize, weight: .semibold, design: style.wordDesign))
          .foregroundStyle(style.inkSecondary)
          .typesettingLanguage(word.deck.language)
          .padding(.bottom, 6)
          .inkDevelop(progress, line: 0)
      }
      Text(word.meaning)
        .font(.system(size: meaningSize, weight: .semibold, design: style.meaningDesign))
        .tracking(-meaningSize * 0.01)
        .foregroundStyle(style.ink)
        .fixedSize(horizontal: false, vertical: true)
        .alignmentGuide(.horizon) { $0[.lastTextBaseline] }
        .inkDevelop(progress, line: 0)
      Text(word.spokenExample)
        .font(.system(size: exampleSize, design: style.bodyDesign))
        .foregroundStyle(style.ink)
        .typesettingLanguage(word.deck.language)
        .lineSpacing(3)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 28)
        .inkDevelop(progress, line: 1)
      Text(word.exampleTranslation)
        .font(.system(size: translationSize, design: style.bodyDesign))
        .italic(style.bodyDesign == .serif)
        .foregroundStyle(style.translationInk ?? style.inkSecondary)
        .lineSpacing(2)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 6)
        .inkDevelop(progress, line: 2)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .risoInk(style.isPrint, seed: 5)
    .background(alignment: .leading) {
      if style.isPrint {
        LightPool(brightness: progress)
          .frame(width: meaningSize * 11, height: meaningSize * 8)
          .offset(x: -meaningSize * 2.2)
      }
    }
    .onChange(of: isRevealed, initial: true) { _, revealed in
      withAnimation(revealed ? .smooth(duration: 0.8) : .smooth(duration: 0.25)) {
        timedProgress = revealed ? 1 : 0
      }
    }
    .animation(.smooth(duration: 0.4), value: openingProgress)
    .accessibilityElement(children: .combine)
    .accessibilityHidden(!isRevealed)
  }
}
