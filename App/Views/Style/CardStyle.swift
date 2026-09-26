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
  /// A second ink printed a hair out of register beneath the word.
  var underprint: Color? = nil
  /// The ink for the note under the word, in place of the secondary ink.
  var noteInk: Color? = nil
  /// The ink for the example's translation, in place of the secondary ink.
  var translationInk: Color? = nil
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

  /// Whether the look is a print, with its type and marks laid down as ink.
  var isPrint: Bool {
    surface == .paper
  }

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

  /// Riso: the screen is a sheet of cream stock printed in navy, with vermilion, teal, and
  /// mustard as spot inks. New York for the words.
  static let riso = CardStyle(
    canvas: .riso,
    surface: .paper,
    ink: RisoInk.navy,
    inkSecondary: RisoInk.navy.opacity(0.72),
    inkTertiary: RisoInk.navy.opacity(0.45),
    track: RisoInk.navy.opacity(0.14),
    accent: RisoInk.vermilion,
    underprint: RisoInk.vermilion,
    noteInk: RisoInk.vermilion,
    translationInk: RisoInk.teal,
    wordDesign: .serif,
    wordWeight: .heavy,
    meaningDesign: .serif,
    bodyDesign: .serif,
    hasGrain: true,
    noteDesign: .monospaced,
    glassTint: RisoInk.paper.opacity(0.55),
    glassIsClear: true,
    usesSwatches: true,
    cornerRadius: 0,
    listPaper: (RisoInk.paper, Color.white.opacity(0.45))
  )

  /// Card: one white card on the grouped background, rounded type.
  static let card = CardStyle(
    canvas: .solid(Color(.systemGroupedBackground)),
    surface: .card,
    accent: coral,
    wordDesign: .rounded
  )
}

/// The stock and inks of the riso print, sampled from a riso-style illustration.
enum RisoInk {
  /// The sheet: uncoated cream stock.
  static let paper = Color(red: 0.949, green: 0.922, blue: 0.859)
  /// The main ink, a deep federal blue. All type is printed in it.
  static let navy = Color(red: 0.204, green: 0.267, blue: 0.424)
  static let vermilion = Color(red: 0.886, green: 0.345, blue: 0.231)
  static let teal = Color(red: 0.016, green: 0.518, blue: 0.486)
  static let mustard = Color(red: 0.949, green: 0.769, blue: 0.263)
  static let pink = Color(red: 0.925, green: 0.584, blue: 0.635)
  /// The warm brown of a shadow cast on paper.
  static let shade = Color(red: 0.32, green: 0.22, blue: 0.12)
  static let all = [navy, vermilion, teal, mustard, pink]
}

extension EnvironmentValues {
  @Entry var cardStyle = CardStyle.keynote
}
