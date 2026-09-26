import SwiftUI

/// "Today · 12 of 20 words", set like a running head over a ruled line that fills in as the
/// day's words are learned.
struct DailyProgressHeader: View {
  var known: Int
  var total: Int

  @Environment(\.cardStyle) private var style
  @Environment(\.displayScale) private var displayScale
  @ScaledMetric(relativeTo: .footnote) private var textSize = 15

  private var fraction: CGFloat {
    total > 0 ? min(CGFloat(known) / CGFloat(total), 1) : 0
  }

  var body: some View {
    HStack(spacing: 7) {
      Text("Today")
        .foregroundStyle(style.ink)
      Text("·")
        .foregroundStyle(style.inkTertiary)
      Text("\(known) of \(total) words")
        .foregroundStyle(style.inkSecondary)
        .monospacedDigit()
        .contentTransition(.numericText(value: Double(known)))
    }
    .font(style.caption.font(size: textSize))
    .tracking(0.4)
    .padding(.bottom, 9)
    .overlay(alignment: .bottom) {
      rule
    }
    .animation(.smooth(duration: 0.6), value: known)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Today")
    .accessibilityValue("\(known) of \(total) words")
  }

  /// A hairline in ink, with the day's progress laid over it in the accent.
  private var rule: some View {
    GeometryReader { proxy in
      ZStack(alignment: .leading) {
        Rectangle()
          .fill(style.rule)
          .frame(height: 1 / displayScale)
        Capsule()
          .fill(style.accent)
          .frame(width: proxy.size.width * fraction, height: 1.5)
      }
      .frame(maxHeight: .infinity)
    }
    .frame(height: 2)
  }
}
