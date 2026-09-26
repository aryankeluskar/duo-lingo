import SwiftUI

/// Develops a line of the answer like ink: from a soft blur to sharp, drifting up a few points.
/// `progress` runs from 0 to 1 across the whole answer and each line takes its turn within it,
/// so whether time or the hinge drives the progress, the lines develop one after another.
struct InkDevelop: ViewModifier, Animatable {
  var progress: Double
  var line: Int
  /// How much of the undeveloped line shows. A faint smudge veils the answer without giving it away.
  var restingOpacity: Double

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var animatableData: Double {
    get { progress }
    set { progress = newValue }
  }

  func body(content: Content) -> some View {
    let amount = Self.amount(of: progress, line: line)
    content
      .opacity(restingOpacity + (1 - restingOpacity) * amount)
      .blur(radius: 14 * (1 - amount))
      .offset(y: reduceMotion ? 0 : 7 * (1 - amount))
  }

  /// Each line starts a little after the one above it and develops over half the answer's progress.
  private static func amount(of progress: Double, line: Int) -> Double {
    let start = Double(line) * 0.14
    let t = min(max((progress - start) / 0.5, 0), 1)
    return t * t * (3 - 2 * t)
  }
}

extension View {
  func inkDevelop(_ progress: Double, line: Int, restingOpacity: Double = 0) -> some View {
    modifier(InkDevelop(progress: progress, line: line, restingOpacity: restingOpacity))
  }
}
