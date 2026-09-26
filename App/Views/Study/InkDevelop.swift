import SwiftUI

/// Develops a line of the answer like ink: from a soft blur to sharp, drifting up a few points.
/// Lines develop one after another by `line`.
struct InkDevelop: ViewModifier {
  var isDeveloped: Bool
  var line: Int
  /// How much of the undeveloped line shows. A faint smudge veils the answer without giving it away.
  var restingOpacity: Double

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  func body(content: Content) -> some View {
    content
      .opacity(isDeveloped ? 1 : restingOpacity)
      .blur(radius: isDeveloped ? 0 : 14)
      .offset(y: isDeveloped || reduceMotion ? 0 : 7)
      .animation(animation, value: isDeveloped)
  }

  private var animation: Animation {
    guard isDeveloped else { return .smooth(duration: 0.25) }
    let delay = 0.08 + Double(line) * 0.07
    return reduceMotion ? .smooth(duration: 0.4).delay(delay) : .smooth(duration: 0.5).delay(delay)
  }
}

extension View {
  func inkDevelop(_ isDeveloped: Bool, line: Int, restingOpacity: Double = 0) -> some View {
    modifier(InkDevelop(isDeveloped: isDeveloped, line: line, restingOpacity: restingOpacity))
  }
}
