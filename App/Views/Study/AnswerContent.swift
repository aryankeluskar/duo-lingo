import SwiftUI

/// The meaning, a hairline, the example, and its translation, developed line by line.
struct AnswerContent: View {
  var word: Word
  var isRevealed: Bool
  /// Shows the term above the meaning, for a single card with no question page beside it.
  var showsTerm = false
  var restingOpacity: Double = 0

  @Environment(\.cardStyle) private var style
  @Environment(\.displayScale) private var displayScale
  @ScaledMetric(relativeTo: .title2) private var termSize = 22
  @ScaledMetric(relativeTo: .title) private var meaningSize = 30
  @ScaledMetric(relativeTo: .body) private var exampleSize = 18
  @ScaledMetric(relativeTo: .subheadline) private var translationSize = 15
  @ScaledMetric(relativeTo: .caption) private var labelSize = 12
  @State private var isDeveloped = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if showsTerm {
        Text(word.spokenTerm)
          .font(style.word.font(size: termSize))
          .foregroundStyle(style.inkSecondary)
          .typesettingLanguage(.init(identifier: "ja"))
          .padding(.bottom, 10)
          .inkDevelop(isDeveloped, line: 0, restingOpacity: restingOpacity)
      }
      Text(word.meaning)
        .font(style.meaning.font(size: meaningSize))
        .foregroundStyle(style.ink)
        .fixedSize(horizontal: false, vertical: true)
        .alignmentGuide(.horizon) { $0[.lastTextBaseline] }
        .inkDevelop(isDeveloped, line: 0, restingOpacity: restingOpacity)
      Rectangle()
        .fill(style.rule)
        .frame(height: 1 / displayScale)
        .padding(.vertical, 22)
        .inkDevelop(isDeveloped, line: 1, restingOpacity: restingOpacity)
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 8) {
        Text("Example")
          .font(style.label.font(size: labelSize))
          .foregroundStyle(style.inkTertiary)
        Text(word.spokenExample)
          .font(style.example.font(size: exampleSize))
          .foregroundStyle(style.ink)
          .typesettingLanguage(.init(identifier: "ja"))
          .lineSpacing(4)
          .fixedSize(horizontal: false, vertical: true)
      }
      .inkDevelop(isDeveloped, line: 2, restingOpacity: restingOpacity)
      Text(word.exampleTranslation)
        .font(style.translation.font(size: translationSize))
        .foregroundStyle(style.inkSecondary)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 6)
        .inkDevelop(isDeveloped, line: 3, restingOpacity: restingOpacity)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .onChange(of: isRevealed, initial: true) { _, revealed in
      isDeveloped = revealed
    }
    .accessibilityElement(children: .combine)
    .accessibilityHidden(!isRevealed)
  }
}
