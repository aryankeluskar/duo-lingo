import SwiftUI

extension View {
  /// Screens the view into halftone dots of one ink and overprints them on what's beneath. The
  /// view's opacity is the tone, so a gradient drawn in black prints as dots that grow and shrink.
  func risoPlate(_ ink: Color, angle: Angle = .degrees(45), pitch: CGFloat = 3.4, seed: Float = 0) -> some View {
    layerEffect(
      ShaderLibrary.risoHalftone(.float(pitch), .float(angle.radians), .color(ink), .float(seed)),
      maxSampleOffset: CGSize(width: pitch * 2, height: pitch * 2)
    )
    .blendMode(.multiply)
  }

  /// Prints a solid of ink: uneven density, the odd skip, and an edge that sits in the paper.
  func risoInk(seed: Float = 0) -> some View {
    distortionEffect(ShaderLibrary.risoRoughen(.float(seed)), maxSampleOffset: CGSize(width: 1, height: 1))
      .colorEffect(ShaderLibrary.risoInk(.float(seed)))
  }

  /// Prints the view as ink when the look is a print, and leaves it alone otherwise.
  @ViewBuilder
  func risoInk(_ isPrint: Bool, seed: Float = 0) -> some View {
    if isPrint {
      risoInk(seed: seed)
    } else {
      self
    }
  }
}
