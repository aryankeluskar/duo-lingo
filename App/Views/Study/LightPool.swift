import SwiftUI

/// A small lamp's pool of light on the paper, printed in mustard: dense where the light is
/// brightest and thinning to nothing at its edge.
struct LightPool: View {
  var brightness: Double = 1

  var body: some View {
    Rectangle()
      .fill(
        EllipticalGradient(
          stops: [
            .init(color: .black.opacity(0.3 * brightness), location: 0),
            .init(color: .black.opacity(0.17 * brightness), location: 0.3),
            .init(color: .black.opacity(0.06 * brightness), location: 0.6),
            .init(color: .black.opacity(0.015 * brightness), location: 0.85),
            .init(color: .clear, location: 1),
          ],
          center: .center,
          startRadiusFraction: 0,
          endRadiusFraction: 0.5
        )
      )
      .risoPlate(RisoInk.mustard, angle: .degrees(30), pitch: 3.4, seed: 11)
      .allowsHitTesting(false)
      .accessibilityHidden(true)
  }
}
