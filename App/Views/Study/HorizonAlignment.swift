import SwiftUI

extension VerticalAlignment {
  /// The line the eye reads straight across the fold: the baseline of the word on one page
  /// and of its meaning on the other.
  static let horizon = VerticalAlignment(HorizonAlignment.self)
}

/// A little above the middle of a page, where the eye comes to rest.
private enum HorizonAlignment: AlignmentID {
  static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context.height * 0.42
  }
}
