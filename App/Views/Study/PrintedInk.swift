import SwiftUI

/// Prints type the way a riso does: a second ink laid a hair out of register beneath it, and
/// both inks laid down unevenly, so the paper glows through.
struct PrintedInk: ViewModifier {
  /// The ink printed beneath, slightly off register.
  var underprint: Color

  func body(content: Content) -> some View {
    content
      .risoInk(seed: 1)
      .background {
        Rectangle()
          .fill(underprint)
          .mask { content }
          // Off to the upper leading side, so it reads as a plate out of register, not a shadow.
          .offset(x: -1.3, y: -0.8)
          .risoInk(seed: 7)
          .blendMode(.multiply)
      }
  }
}

extension View {
  /// Prints the view over an off-register underprint, when the look has one.
  @ViewBuilder
  func printedInk(_ underprint: Color?) -> some View {
    if let underprint {
      modifier(PrintedInk(underprint: underprint))
    } else {
      self
    }
  }
}
