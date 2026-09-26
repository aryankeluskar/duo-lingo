import SwiftUI

/// Presses the card in slightly the moment a finger lands.
struct CardPressStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.985 : 1)
      .animation(.snappy(duration: 0.2), value: configuration.isPressed)
  }
}
