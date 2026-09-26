import SwiftUI

/// Everything that defines how the study screens look: what sits behind the words, what the
/// words sit on, and the one accent color.
struct CardStyle {
  enum Canvas {
    case solid(Color)
    /// A soft mesh of color that shifts hue from card to card.
    case mesh
  }

  enum Surface {
    /// Words sit straight on the canvas.
    case none
    /// A white card lifted by a soft two-layer shadow.
    case card
    /// A Liquid Glass panel.
    case glass
  }

  var canvas: Canvas
  var surface: Surface
  var ink: Color = .primary
  var inkSecondary: Color = .secondary
  var inkTertiary: Color = Color(.tertiaryLabel)
  var track: Color = Color(.quaternaryLabel)
  var accent: Color
  var wordDesign: Font.Design = .default
  var cornerRadius: CGFloat = 34

  /// The opaque color behind a card that has no surface of its own.
  var solidCanvas: Color {
    if case .solid(let color) = canvas { color } else { .clear }
  }
}

extension CardStyle {
  /// A warm coral, used only for progress and the star.
  static let coral = Color(red: 1.0, green: 0.39, blue: 0.24)

  /// Keynote: pure white, big type, nothing else.
  static let keynote = CardStyle(
    canvas: .solid(Color(.systemBackground)),
    surface: .none,
    accent: coral
  )

  /// Glass: a soft mesh of color behind one Liquid Glass panel.
  static let glass = CardStyle(
    canvas: .mesh,
    surface: .glass,
    accent: coral
  )

  /// Card: one white card on the grouped background, rounded type.
  static let card = CardStyle(
    canvas: .solid(Color(.systemGroupedBackground)),
    surface: .card,
    accent: coral,
    wordDesign: .rounded
  )
}

extension EnvironmentValues {
  @Entry var cardStyle = CardStyle.keynote
}
