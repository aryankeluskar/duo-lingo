import SwiftUI

struct ContentView: View {
  @Environment(StudySession.self) private var session
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.colorScheme) private var colorScheme
  @State private var selectedTab = AppTab.launchTab

  private var style: CardStyle {
    CardLook.current.style(for: colorScheme)
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      Tab("Study", systemImage: "rectangle.stack.fill", value: .study) {
        StudyView()
      }
      Tab("Words", systemImage: "character.book.closed", value: .words) {
        WordsView()
      }
    }
    .environment(\.cardStyle, style)
    .tint(style.accent)
    .modifier(
      HingeTracking { state in
        #if DEBUG
        HingeLog.record(state)
        #endif
        session.updateFold(state, isStudying: selectedTab == .study)
      }
    )
    #if DEBUG
    .task {
      if let link = UserDefaults.standard.string(forKey: "makeDeckFrom"), let url = URL(string: link) {
        do {
          WebDeck.shared.replace(with: try await CardMaker.makeDeck(from: url))
          session.studyWebDeck()
        } catch {
          print("makeDeckFrom failed: \(error)")
        }
      }
    }
    #endif
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        session.refreshDay()
      }
    }
  }
}
