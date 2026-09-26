import SwiftUI

struct ContentView: View {
  @Environment(StudySession.self) private var session
  @Environment(\.scenePhase) private var scenePhase
  @AppStorage("cardLook") private var look = CardLook.system

  var body: some View {
    StudyView()
      .environment(\.cardStyle, look.style)
      .preferredColorScheme(look.colorScheme)
      .modifier(
        HingeTracking { state in
          #if DEBUG
          HingeLog.record(state)
          #endif
          session.updateFold(state)
        }
      )
      .onChange(of: scenePhase) { _, phase in
        if phase == .active {
          session.refreshDay()
        }
      }
  }
}
