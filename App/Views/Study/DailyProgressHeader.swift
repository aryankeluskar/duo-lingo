import SwiftUI

/// "Today  3 of 20" over a short capsule that fills in as the day's words are learned.
struct DailyProgressHeader: View {
  var known: Int
  var total: Int

  @Environment(\.cardStyle) private var style
  @ScaledMetric(relativeTo: .subheadline) private var textSize = 15

  private var fraction: CGFloat {
    total > 0 ? min(CGFloat(known) / CGFloat(total), 1) : 0
  }

  var body: some View {
    if style.usesSwatches {
      swatchBar
    } else {
      capsuleBar
    }
  }

  /// A printer's color bar: a swatch per word, inked as each one is learned.
  private var swatchBar: some View {
    VStack(spacing: 7) {
      HStack(spacing: 8) {
        Text("Today")
          .foregroundStyle(style.ink)
        Text("\(known) / \(total)")
          .foregroundStyle(style.inkSecondary)
          .contentTransition(.numericText(value: Double(known)))
      }
      .font(.system(size: textSize * 0.8, weight: .semibold, design: .monospaced))
      .textCase(.uppercase)
      .tracking(1.2)
      HStack(spacing: 3) {
        ForEach(0..<total, id: \.self) { index in
          RoundedRectangle(cornerRadius: 1.5, style: .continuous)
            .fill(RisoInk.all[index % RisoInk.all.count].opacity(index < known ? 1 : 0.2))
            .frame(width: 8, height: 8)
        }
      }
    }
    .animation(.smooth(duration: 0.5), value: known)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Today")
    .accessibilityValue("\(known) of \(total) words")
  }

  private var capsuleBar: some View {
    VStack(spacing: 8) {
      HStack(spacing: 6) {
        Text("Today")
          .foregroundStyle(style.ink)
        Text("\(known) of \(total)")
          .foregroundStyle(style.inkSecondary)
          .monospacedDigit()
          .contentTransition(.numericText(value: Double(known)))
      }
      .font(.system(size: textSize, weight: .semibold))
      Capsule()
        .fill(style.track)
        .frame(width: 112, height: 4)
        .overlay(alignment: .leading) {
          Capsule()
            .fill(style.accent)
            .frame(width: max(4, 112 * fraction))
        }
    }
    .animation(.smooth(duration: 0.5), value: known)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Today")
    .accessibilityValue("\(known) of \(total) words")
  }
}
