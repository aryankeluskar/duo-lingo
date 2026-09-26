import SwiftUI

/// Everything that defines how the study screens look: what sits behind the words, what the
/// words sit on, and the one accent color.
struct CardStyle {
  enum Canvas {
    case solid(Color)
    /// A soft mesh of color that shifts hue from card to card.
    case mesh
    /// Cream paper printed with halftone ink, like a risograph proof.
    case riso
  }

  enum Surface {
    /// Words sit straight on the canvas.
    case none
    /// A white card lifted by a soft two-layer shadow.
    case card
    /// A Liquid Glass panel.
    case glass
    /// A printed sheet of paper, lifted off the table by a soft shadow.
    case paper
  }

  var canvas: Canvas
  var surface: Surface
  var ink: Color = .primary
  var inkSecondary: Color = .secondary
  var inkTertiary: Color = Color(.tertiaryLabel)
  var track: Color = Color(.quaternaryLabel)
  var accent: Color
  var wordDesign: Font.Design = .default
  var wordWeight: Font.Weight = .bold
  var meaningDesign: Font.Design = .default
  /// The example sentence and its translation; the translation is set in italic when serif.
  var bodyDesign: Font.Design = .default
  /// Paper fibers pressed into the surface.
  var hasGrain = false
  /// The note under the word, set like a printer's annotation when monospaced.
  var noteDesign: Font.Design = .default
  var glassTint: Color = .white.opacity(0.35)
  /// Clear glass, like vellum: what's printed beneath shows through, softened.
  var glassIsClear = false
  /// Progress as a printer's color bar, one swatch per word, instead of a capsule.
  var usesSwatches = false
  var cornerRadius: CGFloat = 34
  /// The sheet lists sit on in place of the grouped background, and their rows.
  var listPaper: (sheet: Color, row: Color)? = nil

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

  /// Riso: a sheet of cream paper printed in halftone ink, on a warm table. New York for the words.
  static let riso = CardStyle(
    canvas: .riso,
    surface: .paper,
    ink: Color(red: 0.13, green: 0.12, blue: 0.14),
    inkSecondary: Color(red: 0.36, green: 0.34, blue: 0.36),
    inkTertiary: Color(red: 0.55, green: 0.52, blue: 0.50),
    track: Color(red: 0.17, green: 0.24, blue: 0.42).opacity(0.14),
    accent: RisoInk.coral,
    wordDesign: .serif,
    wordWeight: .heavy,
    meaningDesign: .serif,
    bodyDesign: .serif,
    hasGrain: true,
    noteDesign: .monospaced,
    glassTint: RisoInk.paper.opacity(0.55),
    glassIsClear: true,
    usesSwatches: true,
    cornerRadius: 12,
    listPaper: (RisoInk.paper, Color.white.opacity(0.5))
  )

  /// Card: one white card on the grouped background, rounded type.
  static let card = CardStyle(
    canvas: .solid(Color(.systemGroupedBackground)),
    surface: .card,
    accent: coral,
    wordDesign: .rounded
  )
}

/// The inks of the riso print.
enum RisoInk {
  static let paper = Color(red: 0.953, green: 0.918, blue: 0.863)
  /// The sheet the words are printed on.
  static let sheet = Color(red: 0.965, green: 0.937, blue: 0.886)
  /// The table the sheet lies on.
  static let table = Color(red: 0.89, green: 0.855, blue: 0.80)
  /// The warm brown of a shadow cast on paper.
  static let shade = Color(red: 0.32, green: 0.22, blue: 0.12)
  static let coral = Color(red: 0.894, green: 0.376, blue: 0.294)
  static let teal = Color(red: 0.12, green: 0.54, blue: 0.50)
  static let mustard = Color(red: 0.95, green: 0.745, blue: 0.27)
  static let navy = Color(red: 0.17, green: 0.24, blue: 0.42)
  static let pink = Color(red: 0.94, green: 0.60, blue: 0.69)
  static let all = [coral, teal, mustard, navy, pink]
}

extension EnvironmentValues {
  @Entry var cardStyle = CardStyle.keynote
}
