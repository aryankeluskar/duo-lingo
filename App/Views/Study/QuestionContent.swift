import SwiftUI

/// The word, set large with plenty of air, and its note beneath it: the reading for Japanese,
/// the part of speech for Spanish.
struct QuestionContent: View {
  var word: Word

  @Environment(\.cardStyle) private var style
  @ScaledMetric(relativeTo: .largeTitle) private var wordSize = 76
  @ScaledMetric(relativeTo: .body) private var noteSize = 17

  var body: some View {
    VStack(spacing: 12) {
      Text(word.spokenTerm)
        .font(.system(size: wordSize, weight: style.wordWeight, design: style.wordDesign))
        .tracking(-wordSize * 0.012)
        .foregroundStyle(style.ink)
        .typesettingLanguage(word.deck.language)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        // Kanji sit about 0.08 em below the Latin baseline, so for Japanese line up the bottoms
        // of the glyphs, not the baselines, to read as one line with the meaning.
        .alignmentGuide(.horizon) { $0[.lastTextBaseline] + (word.deck.usesIdeographs ? wordSize * 0.07 : 0) }
      Text(word.spokenNote)
        .font(.system(size: style.noteDesign == .monospaced ? noteSize * 0.78 : noteSize, weight: .medium, design: style.noteDesign))
        .textCase(style.noteDesign == .monospaced ? .uppercase : nil)
        .tracking(style.noteDesign == .monospaced ? 1.4 : 0)
        .foregroundStyle(style.inkSecondary)
        .typesettingLanguage(word.deck.language)
    }
    .padding(.horizontal, 28)
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
  }
}
