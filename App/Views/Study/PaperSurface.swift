import SwiftUI

/// What a page or a spread sits on: nothing, a white card, or a glass panel.
struct Surface: View {
  /// Fills with the canvas when there's no surface, so a card being dealt away covers the one beneath.
  var isOpaque = false

  @Environment(\.cardStyle) private var style

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
    switch style.surface {
    case .none:
      Rectangle().fill(isOpaque ? style.solidCanvas : .clear)
    case .card:
      shape
        .fill(Color(.secondarySystemGroupedBackground))
        .shadow(color: .black.opacity(0.04), radius: 1, y: 1)
        .shadow(color: .black.opacity(0.07), radius: 28, y: 14)
    case .glass:
      Color.clear
        .glassEffect(.regular, in: shape)
    }
  }
}

/// Everything behind the study screen. The mesh drifts to a new palette with each card.
struct CanvasBackground: View {
  var seed: Int

  @Environment(\.cardStyle) private var style

  var body: some View {
    switch style.canvas {
    case .solid(let color):
      color.ignoresSafeArea()
    case .mesh:
      MeshCanvas(palette: MeshCanvas.palettes[abs(seed) % MeshCanvas.palettes.count])
        .ignoresSafeArea()
        .animation(.smooth(duration: 1.2), value: seed)
    }
  }
}

private struct MeshCanvas: View {
  var palette: [Color]

  var body: some View {
    MeshGradient(
      width: 3,
      height: 3,
      points: [
        [0, 0], [0.55, 0], [1, 0],
        [0, 0.5], [0.45, 0.55], [1, 0.45],
        [0, 1], [0.5, 1], [1, 1],
      ],
      colors: palette
    )
  }

  private static func rgb(_ hex: UInt32) -> Color {
    Color(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }

  /// Pale, luminous palettes: coral dawn, lavender sky, sea glass, apricot.
  static let palettes: [[Color]] = [
    [0xFFE3D6, 0xFFC4B0, 0xFFD3E4, 0xFFD9C2, 0xFF9F85, 0xF5B8DC, 0xFFF0DA, 0xFFC9A8, 0xEEC2F0],
    [0xE4E9FF, 0xC9D5FF, 0xE3D6FF, 0xEAF1FF, 0xA9BEFF, 0xCDB9FF, 0xF1F6FF, 0xC6D8FF, 0xE8DBFF],
    [0xDDF7EE, 0xB7EEDC, 0xCFEBFF, 0xE6FBF3, 0x9FE3CF, 0xB4DDFB, 0xF0FCF7, 0xC4F0E2, 0xD6ECFF],
    [0xFFF1D6, 0xFFDDB0, 0xFFE0D0, 0xFFF4E0, 0xFFC98F, 0xFFC0AE, 0xFFFAEE, 0xFFE2B8, 0xFFD6CC],
  ].map { $0.map(rgb) }
}
