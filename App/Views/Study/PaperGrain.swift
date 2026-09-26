import SwiftUI

/// The tooth of card stock: fine specks and the odd fiber, too faint to notice until you look
/// closely. One tile is generated once from a fixed seed and repeated from the top leading
/// corner, so the grain stays put as the card changes size.
struct PaperGrain: View {
  var grain: CardStyle.Grain

  var body: some View {
    Canvas(rendersAsynchronously: true) { context, size in
      let tile = GrainTile.shared
      for y in stride(from: 0, to: size.height, by: GrainTile.size) {
        for x in stride(from: 0, to: size.width, by: GrainTile.size) {
          var tileContext = context
          tileContext.translateBy(x: x, y: y)
          tileContext.fill(tile.shadeSpecks, with: .color(grain.shade))
          tileContext.fill(tile.lightSpecks, with: .color(grain.light))
          tileContext.stroke(tile.fibers, with: .color(grain.shade), style: StrokeStyle(lineWidth: 0.35, lineCap: .round))
        }
      }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}

/// One square of grain.
private struct GrainTile {
  static let size: CGFloat = 320
  static let shared = GrainTile(seed: 0x5EED_F01D)

  var shadeSpecks = Path()
  var lightSpecks = Path()
  var fibers = Path()

  init(seed: UInt64) {
    var generator = SplitMix64(state: seed)
    let area = Self.size * Self.size
    for _ in 0..<Int(area / 24) {
      shadeSpecks.addRect(Self.speck(using: &generator))
    }
    for _ in 0..<Int(area / 40) {
      lightSpecks.addRect(Self.speck(using: &generator))
    }
    for _ in 0..<Int(area / 900) {
      let start = Self.point(using: &generator)
      let angle = Double.random(in: 0..<(2 * .pi), using: &generator)
      let length = CGFloat.random(in: 2...7, using: &generator)
      let bend = CGFloat.random(in: -1...1, using: &generator)
      let end = CGPoint(x: start.x + cos(angle) * length, y: start.y + sin(angle) * length)
      let control = CGPoint(
        x: (start.x + end.x) / 2 - sin(angle) * bend,
        y: (start.y + end.y) / 2 + cos(angle) * bend
      )
      fibers.move(to: start)
      fibers.addQuadCurve(to: end, control: control)
    }
  }

  private static func point(using generator: inout SplitMix64) -> CGPoint {
    CGPoint(x: .random(in: 0..<size, using: &generator), y: .random(in: 0..<size, using: &generator))
  }

  private static func speck(using generator: inout SplitMix64) -> CGRect {
    let side = CGFloat.random(in: 0.4...1.1, using: &generator)
    return CGRect(origin: point(using: &generator), size: CGSize(width: side, height: side))
  }
}

/// A small, fast generator with a fixed seed, so every launch draws the same paper.
private struct SplitMix64: RandomNumberGenerator {
  var state: UInt64

  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
  }
}
