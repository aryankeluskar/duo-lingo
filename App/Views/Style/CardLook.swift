import SwiftUI

/// The art direction for the cards.
enum CardLook: String {
  /// Paper and ink: warm off-white stock by day, warm ink on black in Dark Mode.
  case paper
  /// The reference video's system look. Debug builds only, with `-cardLook system`.
  case system

  static var current: CardLook {
    #if DEBUG
    if let look = UserDefaults.standard.string(forKey: "cardLook").flatMap(CardLook.init) {
      return look
    }
    #endif
    return .paper
  }

  func style(for colorScheme: ColorScheme) -> CardStyle {
    switch self {
    case .paper: colorScheme == .dark ? .ink : .paper
    case .system: .system
    }
  }
}
