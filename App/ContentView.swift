import SwiftUI

struct ContentView: View {
  @Environment(StudySession.self) private var session
  @Environment(\.scenePhase) private var scenePhase
  @AppStorage("cardLook") private var look = CardLook.system
  @State private var selectedTab = AppTab.launchTab

  var body: some View {
    TabView(selection: $selectedTab) {
      Tab("Study", systemImage: "rectangle.stack.fill", value: .study) {
        StudyView()
      }
      Tab("Words", systemImage: "character.book.closed", value: .words) {
        WordsView()
      }
    }
    .environment(\.cardStyle, look.style)
    .tint(look.style.accent)
    .preferredColorScheme(look.colorScheme)
    .modifier(
      HingeTracking { state in
        #if DEBUG
        HingeLog.record(state)
        #endif
        session.updateFold(state, isStudying: selectedTab == .study)
      }
    )
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        session.refreshDay()
      }
    }
  }
}
