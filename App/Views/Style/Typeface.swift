import SwiftUI

/// A font recipe that takes its size from the view, so each view can scale it with Dynamic Type.
struct Typeface {
  var name: String?
  var weight = Font.Weight.regular
  var design = Font.Design.default
  var isItalic = false
  var usesSmallCaps = false

  func font(size: CGFloat) -> Font {
    var font = name.map { Font.custom($0, fixedSize: size) } ?? .system(size: size, weight: weight, design: design)
    if isItalic {
      font = font.italic()
    }
    if usesSmallCaps {
      font = font.lowercaseSmallCaps()
    }
    return font
  }
}
