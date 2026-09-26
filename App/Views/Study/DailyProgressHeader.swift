import SwiftUI

/// "Today  12 of 20 words" over a thin progress bar, as in the reference video.
struct DailyProgressHeader: View {
  var known: Int
  var total: Int

  @Environment(\.cardStyle) private var style

  var body: some View {
    HStack(spacing: 10) {
      Text("Today")
        .fontWeight(.semibold)
        .foregroundStyle(style.ink)
      Text("\(known) of \(total) words")
        .foregroundStyle(style.inkSecondary)
        .monospacedDigit()
        .contentTransition(.numericText(value: Double(known)))
    }
    .font(.footnote)
    .padding(.bottom, 8)
    .overlay(alignment: .bottom) {
      ProgressView(value: Double(known), total: Double(max(total, 1)))
        .tint(style.accent)
    }
    .animation(.smooth, value: known)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Today")
    .accessibilityValue("\(known) of \(total) words")
  }
}
