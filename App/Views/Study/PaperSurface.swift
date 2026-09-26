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
      shape
        .fill(RisoInk.sheet)
        .overlay {
          HalftonePrint(seed: seed)
            .id(seed)
            .transition(.opacity)
            .clipShape(shape)
        }
        .overlay {
          PaperGrain().clipShape(shape)
        }
        .compositingGroup()
        .shadow(color: RisoInk.shade.opacity(0.10), radius: 1, y: 1)
        .shadow(color: RisoInk.shade.opacity(0.14), radius: 30, y: 16)
        .allowsHitTesting(false)
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

  var body: some View {
    switch style.canvas {
    case .solid(let color):
      color.ignoresSafeArea()
    case .riso:
      PrintTable()
        .ignoresSafeArea()
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

/// Halftone ink printed on the sheet: a few blobs, each on its own screen, overprinting where
/// they meet and never quite in register.
private struct HalftonePrint: View {
  var seed: Int

  var body: some View {
    Canvas { context, size in
      context.blendMode = .multiply
      let step: CGFloat = 6.5
      for (index, blob) in Self.blobs(seed: seed, in: size).enumerated() {
        var dots = Path()
        let shift = CGFloat(index) * 2.1
        var y = shift.truncatingRemainder(dividingBy: step)
        while y < size.height {
          var x = (shift * 1.4).truncatingRemainder(dividingBy: step)
          while x < size.width {
            let dx = (x - blob.center.x) / blob.radius.width
            let dy = (y - blob.center.y) / blob.radius.height
            let d = dx * dx + dy * dy
            if d < 1 {
              let r = (1 - d) * step * 0.5
              if r > 0.4 {
                dots.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
              }
            }
            x += step
          }
          y += step
        }
        context.fill(dots, with: .color(blob.color.opacity(0.85)))
      }
    }
    .drawingGroup()
  }

  struct Blob {
    var center: CGPoint
    var radius: CGSize
    var color: Color
  }

  /// Three blobs of ink in the corners, clear of the words, placed and colored for each card.
  static func blobs(seed: Int, in size: CGSize) -> [Blob] {
    var state = UInt64(truncatingIfNeeded: seed &* 2654435761 &+ 97)
    func next() -> CGFloat {
      state = state &* 6364136223846793005 &+ 1442695040888963407
      return CGFloat((state >> 33) % 10_000) / 10_000
    }
    let anchors: [CGPoint] = [CGPoint(x: 0.04, y: 0.96), CGPoint(x: 0.96, y: 0.04), CGPoint(x: 0.84, y: 1.0)]
    let span = min(size.width, size.height)
    return anchors.enumerated().map { index, anchor in
      let color = RisoInk.all[(abs(seed) + index * 2) % RisoInk.all.count]
      let center = CGPoint(
        x: (anchor.x + (next() - 0.5) * 0.12) * size.width,
        y: (anchor.y + (next() - 0.5) * 0.12) * size.height
      )
      let r = span * (0.30 + next() * 0.12)
      return Blob(center: center, radius: CGSize(width: r * 1.25, height: r), color: color)
    }
  }
}

/// The table under the sheet, with a printer's registration marks at the edges and fold marks
/// at the hinge.
private struct PrintTable: View {
  var body: some View {
    Canvas { context, size in
      context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(RisoInk.table))
      let mark = GraphicsContext.Shading.color(RisoInk.navy.opacity(0.45))
      for point in [CGPoint(x: 18, y: size.height / 2), CGPoint(x: size.width - 18, y: size.height / 2)] {
        var cross = Path()
        cross.addEllipse(in: CGRect(x: point.x - 6, y: point.y - 6, width: 12, height: 12))
        cross.move(to: CGPoint(x: point.x - 11, y: point.y))
        cross.addLine(to: CGPoint(x: point.x + 11, y: point.y))
        cross.move(to: CGPoint(x: point.x, y: point.y - 11))
        cross.addLine(to: CGPoint(x: point.x, y: point.y + 11))
        context.stroke(cross, with: mark, lineWidth: 0.75)
      }
      var fold = Path()
      fold.move(to: CGPoint(x: size.width / 2, y: 4))
      fold.addLine(to: CGPoint(x: size.width / 2, y: 22))
      fold.move(to: CGPoint(x: size.width / 2, y: size.height - 22))
      fold.addLine(to: CGPoint(x: size.width / 2, y: size.height - 4))
      context.stroke(fold, with: mark, style: StrokeStyle(lineWidth: 0.75, dash: [3, 3]))
    }
  }
}

/// Fine specks and fibers, the tooth of uncoated paper.
private struct PaperGrain: View {
  var body: some View {
    Canvas { context, size in
      var state: UInt64 = 0x9E3779B97F4A7C15
      func next() -> CGFloat {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat((state >> 33) % 100_000) / 100_000
      }
      var dark = Path()
      var light = Path()
      let count = Int(size.width * size.height / 90)
      for index in 0..<count {
        let x = next() * size.width
        let y = next() * size.height
        let r = 0.35 + next() * 0.7
        let speck = CGRect(x: x, y: y, width: r, height: r)
        if index % 3 == 0 { light.addEllipse(in: speck) } else { dark.addEllipse(in: speck) }
      }
      context.fill(dark, with: .color(Color(red: 0.35, green: 0.28, blue: 0.2).opacity(0.10)))
      context.fill(light, with: .color(.white.opacity(0.35)))
      var fibers = Path()
      for _ in 0..<Int(size.width * size.height / 9000) {
        let start = CGPoint(x: next() * size.width, y: next() * size.height)
        let angle = next() * .pi * 2
        let length = 4 + next() * 10
        fibers.move(to: start)
        fibers.addQuadCurve(
          to: CGPoint(x: start.x + cos(angle) * length, y: start.y + sin(angle) * length),
          control: CGPoint(x: start.x + cos(angle + 0.6) * length * 0.5, y: start.y + sin(angle + 0.6) * length * 0.5)
        )
      }
      context.stroke(fibers, with: .color(Color(red: 0.35, green: 0.28, blue: 0.2).opacity(0.07)), lineWidth: 0.5)
    }
    .drawingGroup()
  }
}
