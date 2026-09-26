import SwiftUI

/// The card stock behind a page or a spread.
struct PaperSurface: View {
  @Environment(\.cardStyle) private var style

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
    shape
      .fill(style.paper)
      .overlay {
        shape.strokeBorder(
          LinearGradient(colors: [style.paperEdgeHighlight, style.paperEdge], startPoint: .top, endPoint: .bottom),
          lineWidth: 0.75
        )
      }
      .shadow(color: style.shadow, radius: 20, y: 8)
  }
}
