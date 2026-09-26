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

  /// A printer's color bar: a swatch per word in runs of each ink, a pale halftone tint until
  /// the word is learned and printed solid once it is.
  private var swatchBar: some View {
    HStack(spacing: 12) {
      HStack(spacing: 7) {
        Text("Today")
        Text("\(known) / \(total)")
          .foregroundStyle(style.inkSecondary)
          .contentTransition(.numericText(value: Double(known)))
      }
      .font(.system(size: textSize * 0.68, weight: .medium, design: .monospaced))
      .textCase(.uppercase)
      .tracking(1.6)
      .foregroundStyle(style.ink)
      HStack(spacing: 2) {
        ForEach(0..<total, id: \.self) { index in
          Swatch(color: RisoInk.all[index * RisoInk.all.count / max(total, 1)], isPrinted: index < known)
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

/// One patch of the color bar: a pale halftone tint of its ink, or the ink printed solid.
private struct Swatch: View {
  var color: Color
  var isPrinted: Bool

  var body: some View {
    ZStack {
      Rectangle()
        .fill(.black.opacity(0.32))
        .risoPlate(color, angle: .degrees(45), pitch: 2.4, seed: 17)
      Rectangle()
        .fill(color)
        .risoInk(seed: 19)
        .opacity(isPrinted ? 1 : 0)
    }
    .frame(width: 10, height: 10)
  }
}
