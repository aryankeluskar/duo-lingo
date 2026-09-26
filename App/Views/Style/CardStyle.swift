import SwiftUI

/// Everything that defines how a card looks: the paper, the ink, and the type.
struct CardStyle {
  var canvas: Color
  var paper: Color
  var paperEdge: Color
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
  var cornerRadius: CGFloat = 28
}

extension CardStyle {
  /// The reference video: a quiet system card with a hairline spine.
  static let system = CardStyle(
    canvas: Color(.systemBackground),
    paper: Color(.secondarySystemBackground),
    paperEdge: .primary.opacity(0.06),
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
    shadow: Color(red: 0.32, green: 0.24, blue: 0.12).opacity(0.16),
    ink: Color(red: 0.13, green: 0.11, blue: 0.09),
    inkSecondary: Color(red: 0.42, green: 0.38, blue: 0.33),
    inkTertiary: Color(red: 0.58, green: 0.54, blue: 0.48),
    rule: Color(red: 0.45, green: 0.37, blue: 0.25).opacity(0.24),
    accent: Color(red: 0.76, green: 0.25, blue: 0.17),
    creaseShadow: Color(red: 0.30, green: 0.22, blue: 0.10).opacity(0.14),
    creaseHighlight: .white.opacity(0.7),
    showsSpineRule: false,
    word: Typeface(name: "HiraMinProN-W6"),
    meaning: Typeface(weight: .semibold, design: .serif),
    example: Typeface(name: "HiraMinProN-W3"),
    translation: Typeface(design: .serif, isItalic: true),
    caption: Typeface(design: .serif, usesSmallCaps: true),
    label: Typeface(weight: .semibold, design: .serif, usesSmallCaps: true)
  )

  /// Ink on black: the paper look for the dark, with warm white type.
  static let ink = CardStyle(
    canvas: .black,
    paper: Color(red: 0.075, green: 0.071, blue: 0.067),
    paperEdge: .white.opacity(0.09),
    shadow: .clear,
    ink: Color(red: 0.95, green: 0.93, blue: 0.89),
    inkSecondary: Color(red: 0.64, green: 0.61, blue: 0.56),
    inkTertiary: Color(red: 0.46, green: 0.44, blue: 0.41),
    rule: .white.opacity(0.13),
    accent: Color(red: 0.93, green: 0.44, blue: 0.32),
    creaseShadow: .black.opacity(0.85),
    creaseHighlight: .white.opacity(0.05),
    showsSpineRule: false,
    word: Typeface(name: "HiraMinProN-W6"),
    meaning: Typeface(weight: .semibold, design: .serif),
    example: Typeface(name: "HiraMinProN-W3"),
    translation: Typeface(design: .serif, isItalic: true),
    caption: Typeface(design: .serif, usesSmallCaps: true),
    label: Typeface(weight: .semibold, design: .serif, usesSmallCaps: true)
  )
}

extension EnvironmentValues {
  @Entry var cardStyle = CardStyle.system
}
