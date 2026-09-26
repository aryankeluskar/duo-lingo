import SwiftUI

/// Everything that defines how a card looks: the paper, the ink, and the type.
struct CardStyle {
  var canvas: Color
  var paper: Color
  var paperEdge: Color
  /// The top of the edge, where light catches it. Matches `paperEdge` for an evenly lit card.
  var paperEdgeHighlight: Color
  var shadow: Color
  var ink: Color
  var inkSecondary: Color
  var inkTertiary: Color
  var rule: Color
  var accent: Color
  /// The shading in the valley of the fold. Clear for a flat page.
  var creaseShadow: Color
  /// The light catching the page as it curves out of the fold.
  var creaseHighlight: Color
  var showsSpineRule: Bool
  var word: Typeface
  var meaning: Typeface
  var example: Typeface
  var translation: Typeface
  var caption: Typeface
  var label: Typeface
  /// The texture of the card stock. None for a smooth card.
  var grain: Grain? = nil
  var cornerRadius: CGFloat = 28

  /// Specks and fibers darker and lighter than the paper, each at a whisper of opacity.
  struct Grain {
    var shade: Color
    var light: Color
  }
}

extension CardStyle {
  /// The reference video: a quiet system card with a hairline spine.
  static let system = CardStyle(
    canvas: Color(.systemBackground),
    paper: Color(.secondarySystemBackground),
    paperEdge: .primary.opacity(0.06),
    paperEdgeHighlight: .primary.opacity(0.06),
    shadow: .black.opacity(0.08),
    ink: .primary,
    inkSecondary: .secondary,
    inkTertiary: Color(.tertiaryLabel),
    rule: Color(.separator),
    accent: .accentColor,
    creaseShadow: .clear,
    creaseHighlight: .clear,
    showsSpineRule: true,
    word: Typeface(weight: .bold),
    meaning: Typeface(weight: .bold),
    example: Typeface(weight: .medium),
    translation: Typeface(),
    caption: Typeface(),
    label: Typeface(weight: .semibold)
  )

  /// Paper and ink: warm off-white stock, Mincho for Japanese, New York for English.
  static let paper = CardStyle(
    canvas: Color(red: 0.918, green: 0.898, blue: 0.859),
    paper: Color(red: 0.984, green: 0.973, blue: 0.945),
    paperEdge: Color(red: 0.45, green: 0.37, blue: 0.25).opacity(0.16),
    paperEdgeHighlight: Color(red: 0.45, green: 0.37, blue: 0.25).opacity(0.16),
    shadow: Color(red: 0.32, green: 0.24, blue: 0.12).opacity(0.16),
    ink: Color(red: 0.13, green: 0.11, blue: 0.09),
    inkSecondary: Color(red: 0.42, green: 0.38, blue: 0.33),
    inkTertiary: Color(red: 0.58, green: 0.54, blue: 0.48),
    rule: Color(red: 0.45, green: 0.37, blue: 0.25).opacity(0.24),
    accent: Color(red: 0.76, green: 0.25, blue: 0.17),
    creaseShadow: Color(red: 0.30, green: 0.22, blue: 0.10).opacity(0.14),
    creaseHighlight: .white.opacity(0.45),
    showsSpineRule: false,
    word: Typeface(name: "HiraMinProN-W6"),
    meaning: Typeface(weight: .semibold, design: .serif),
    example: Typeface(name: "HiraMinProN-W3"),
    translation: Typeface(design: .serif, isItalic: true),
    caption: Typeface(design: .serif, usesSmallCaps: true),
    label: Typeface(weight: .semibold, design: .serif, usesSmallCaps: true),
    grain: Grain(shade: Color(red: 0.30, green: 0.22, blue: 0.10).opacity(0.03), light: .white.opacity(0.4))
  )

  /// Ink on black: the paper look for Dark Mode, with warm white type. A faint warm edge,
  /// brightest along the top, lifts the card off the black.
  static let ink = CardStyle(
    canvas: .black,
    paper: Color(red: 0.078, green: 0.073, blue: 0.067),
    paperEdge: Color(red: 1, green: 0.86, blue: 0.68).opacity(0.07),
    paperEdgeHighlight: Color(red: 1, green: 0.86, blue: 0.68).opacity(0.22),
    shadow: Color(red: 1, green: 0.82, blue: 0.6).opacity(0.05),
    ink: Color(red: 0.95, green: 0.93, blue: 0.89),
    inkSecondary: Color(red: 0.64, green: 0.61, blue: 0.56),
    inkTertiary: Color(red: 0.46, green: 0.44, blue: 0.41),
    rule: .white.opacity(0.13),
    accent: Color(red: 0.93, green: 0.44, blue: 0.32),
    creaseShadow: .black.opacity(0.38),
    creaseHighlight: Color(red: 1, green: 0.9, blue: 0.78).opacity(0.035),
    showsSpineRule: false,
    word: Typeface(name: "HiraMinProN-W6"),
    meaning: Typeface(weight: .semibold, design: .serif),
    example: Typeface(name: "HiraMinProN-W3"),
    translation: Typeface(design: .serif, isItalic: true),
    caption: Typeface(design: .serif, usesSmallCaps: true),
    label: Typeface(weight: .semibold, design: .serif, usesSmallCaps: true),
    grain: Grain(shade: .black.opacity(0.2), light: Color(red: 1, green: 0.9, blue: 0.78).opacity(0.025))
  )
}

extension EnvironmentValues {
  @Entry var cardStyle = CardStyle.system
}
