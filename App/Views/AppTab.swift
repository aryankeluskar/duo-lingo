import Foundation

enum AppTab: String {
  case study
  case words

  static var launchTab: AppTab {
    #if DEBUG
    if let tab = UserDefaults.standard.string(forKey: "launchTab").flatMap(AppTab.init) {
      return tab
    }
    #endif
    return .study
  }
}
