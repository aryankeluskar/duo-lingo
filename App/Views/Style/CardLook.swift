import SwiftUI

/// The art direction for the cards.
enum CardLook: String, CaseIterable, Identifiable {
  /// The reference video: system colors and SF Pro.
  case system
  /// Warm off-white paper, Hiragino Mincho and New York, a soft crease at the hinge.
  case paper
  /// Warm ink on black.
  case ink

  var id: Self { self }

  var style: CardStyle {
    switch self {
    case .system: .system
    case .paper: .paper
    case .ink: .ink
    }
  }

  /// Paper and ink are printed looks with a fixed appearance; the system look follows Dark Mode.
  var colorScheme: ColorScheme? {
    switch self {
    case .system: nil
    case .paper: .light
    case .ink: .dark
    }
  }
}
