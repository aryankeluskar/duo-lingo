import SwiftUI

/// The art direction for the study screens.
enum CardLook: String {
  case keynote
  case glass
  case card

  static var current: CardLook {
    #if DEBUG
    if let look = UserDefaults.standard.string(forKey: "cardLook").flatMap(CardLook.init) {
      return look
    }
    #endif
    return .keynote
  }

  func style(for colorScheme: ColorScheme) -> CardStyle {
    switch self {
    case .keynote: .keynote
    case .glass: .glass
    case .card: .card
    }
  }
}
