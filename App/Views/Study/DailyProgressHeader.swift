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
