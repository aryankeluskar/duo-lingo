import SwiftUI

@main
struct AppDefinition: App {
  @State private var session = StudySession()

  init() {
    CardMaker.keepLaunchKey()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(session)
        .preferredColorScheme(.light)
    }
  }
}
