import SwiftUI

/// What a page or a spread sits on: nothing, a white card, or a glass panel.
struct Surface: View {
  /// Fills with the canvas when there's no surface, so a card being dealt away covers the one beneath.
  var isOpaque = false
  /// Picks the print on a paper surface, so each card carries its own.
  var seed = 0

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
    case .paper:
      // The screen is the sheet, so a page needs its own paper only to cover the one beneath
      // while it's dealt away. The shadow shows only once its edge comes into view.
      if isOpaque {
        PrintSheet()
          .shadow(color: RisoInk.shade.opacity(0.25), radius: 22, x: 6)
      } else {
        Color.clear
      }
    case .glass:
      Color.clear
        .glassEffect(Self.glass(tint: style.glassTint, clear: style.glassIsClear), in: shape)
        .overlay {
          if style.hasGrain {
            PaperGrain().clipShape(shape).allowsHitTesting(false)
          }
        }
    }
  }
}

extension Surface {
  static func glass(tint: Color, clear: Bool) -> Glass {
    #if DEBUG
    switch UserDefaults.standard.string(forKey: "glassKind") {
    case "clear": return .clear
    case "regular": return .regular
    case "milk": return .regular.tint(.white.opacity(0.55))
    case "vellum": return .clear.tint(tint)
    case "frosted": return .regular.tint(tint)
    default: break
    }
    #endif
    return clear ? .clear.tint(tint) : .regular.tint(tint)
  }
}

/// Everything behind the study screen. The mesh drifts to a new palette with each card.
struct CanvasBackground: View {
  var seed: Int

  @Environment(\.cardStyle) private var style
  @Environment(StudySession.self) private var session

  var body: some View {
    switch style.canvas {
    case .solid(let color):
      color.ignoresSafeArea()
    case .riso:
      PrintSheet(foldDepth: session.fold.foldDepth)
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

/// The sheet the riso look is printed on. It fills the screen: the display is the paper, and on
/// iPhone Duo the hinge is its fold. Printer's marks sit quietly at the edges, and a halftone
/// shadow gathers in the crease as the display bends.
struct PrintSheet: View {
  /// How sharply the sheet bends at the fold, from 0 lying flat to 1 at a right angle.
  var foldDepth: Double = 0

  var body: some View {
    GeometryReader { proxy in
      let crease = Self.crease(in: proxy)
      ZStack {
        Rectangle()
          .fill(RisoInk.paper)
          .colorEffect(ShaderLibrary.risoPaper(.boundingRect))
        PaperGrain()
        if let crease {
          CreaseShadow(x: crease, width: proxy.size.width, depth: foldDepth)
            .animation(.smooth(duration: 0.35), value: foldDepth)
        }
        PrintersMarks(crease: crease)
          .risoInk(seed: 13)
      }
    }
    .ignoresSafeArea()
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  /// Where the fold runs down the sheet, when the display has one.
  private static func crease(in proxy: GeometryProxy) -> CGFloat? {
    if #available(iOS 27.1, *),
      let fold = proxy.reservedRegions(kind: .division, options: .includeInactive).first,
      fold.frame.height >= fold.frame.width
    {
      return fold.frame.midX
    }
    return nil
  }
}

/// The valley of the fold, printed as a navy halftone: a faint crease lying flat that deepens and
/// widens as the pages rise. The light falls from the trailing side, so the leading wall is darker.
private struct CreaseShadow: View {
  var x: CGFloat
  var width: CGFloat
  var depth: Double

  var body: some View {
    let reach = 12 + 130 * depth
    let strength = 0.1 + 0.5 * depth
    Rectangle()
      .fill(
        LinearGradient(
          stops: Self.profile.map { offset, tone in
            let side = offset < 0 ? 1 : 0.6
            return .init(
              color: .black.opacity(tone * strength * side),
              location: min(max((x + offset * reach) / width, 0), 1)
            )
          },
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .risoPlate(RisoInk.navy, angle: .degrees(45), pitch: 3.6, seed: 21)
      .overlay {
        Path { line in
          line.move(to: CGPoint(x: x, y: 0))
          line.addLine(to: CGPoint(x: x, y: 2000))
        }
        .stroke(RisoInk.navy.opacity(0.22 + 0.25 * depth), lineWidth: 0.6)
      }
  }

  /// The tone across the valley, from one wall to the other.
  private static let profile: [(CGFloat, Double)] = [
    (-1, 0), (-0.7, 0.08), (-0.45, 0.24), (-0.22, 0.55), (-0.06, 0.9), (0, 1),
    (0.06, 0.9), (0.22, 0.55), (0.45, 0.24), (0.7, 0.08), (1, 0),
  ]
}

/// Registration targets at the side edges, crop marks at the corners, and fold marks where the
/// crease meets the edge of the sheet.
private struct PrintersMarks: View {
  var crease: CGFloat?

  var body: some View {
    Canvas { context, size in
      let ink = GraphicsContext.Shading.color(RisoInk.navy.opacity(0.5))
      let hairline: CGFloat = 0.6
      var marks = Path()
      for center in [CGPoint(x: 18, y: size.height / 2), CGPoint(x: size.width - 18, y: size.height / 2)] {
        marks.addEllipse(in: CGRect(x: center.x - 5, y: center.y - 5, width: 10, height: 10))
        marks.move(to: CGPoint(x: center.x - 10, y: center.y))
        marks.addLine(to: CGPoint(x: center.x + 10, y: center.y))
        marks.move(to: CGPoint(x: center.x, y: center.y - 10))
        marks.addLine(to: CGPoint(x: center.x, y: center.y + 10))
      }
      let trim: CGFloat = 30
      for (cx, sx) in [(trim, -1.0), (size.width - trim, 1.0)] {
        for (cy, sy) in [(trim, -1.0), (size.height - trim, 1.0)] {
          // Each mark stands just outside the trim, pointing along the edge it marks.
          marks.move(to: CGPoint(x: cx, y: cy + sy * 4))
          marks.addLine(to: CGPoint(x: cx, y: cy + sy * 14))
          marks.move(to: CGPoint(x: cx + sx * 4, y: cy))
          marks.addLine(to: CGPoint(x: cx + sx * 14, y: cy))
        }
      }
      context.stroke(marks, with: ink, lineWidth: hairline)
      if let crease {
        var fold = Path()
        fold.move(to: CGPoint(x: crease, y: 6))
        fold.addLine(to: CGPoint(x: crease, y: 24))
        fold.move(to: CGPoint(x: crease, y: size.height - 24))
        fold.addLine(to: CGPoint(x: crease, y: size.height - 6))
        context.stroke(fold, with: ink, style: StrokeStyle(lineWidth: hairline, dash: [3, 2.5]))
      }
    }
  }
}

/// The tooth of uncoated stock: a soft mottle, fine specks, and the odd fiber.
private struct PaperGrain: View {
  var body: some View {
    Canvas { context, size in
      var state: UInt64 = 0x9E3779B97F4A7C15
      func next() -> CGFloat {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat((state >> 33) % 100_000) / 100_000
      }
      let fiberInk = Color(red: 0.35, green: 0.28, blue: 0.2)
      var dark = Path()
      var light = Path()
      for index in 0..<Int(size.width * size.height / 110) {
        let r = 0.35 + next() * 0.6
        let speck = CGRect(x: next() * size.width, y: next() * size.height, width: r, height: r)
        if index % 3 == 0 { light.addEllipse(in: speck) } else { dark.addEllipse(in: speck) }
      }
      context.fill(dark, with: .color(fiberInk.opacity(0.09)))
      context.fill(light, with: .color(.white.opacity(0.4)))
      var fibers = Path()
      for _ in 0..<Int(size.width * size.height / 12000) {
        let start = CGPoint(x: next() * size.width, y: next() * size.height)
        let angle = next() * .pi * 2
        let length = 4 + next() * 9
        fibers.move(to: start)
        fibers.addQuadCurve(
          to: CGPoint(x: start.x + cos(angle) * length, y: start.y + sin(angle) * length),
          control: CGPoint(x: start.x + cos(angle + 0.6) * length * 0.5, y: start.y + sin(angle + 0.6) * length * 0.5)
        )
      }
      context.stroke(fibers, with: .color(fiberInk.opacity(0.06)), lineWidth: 0.5)
    }
    .drawingGroup()
  }
}
