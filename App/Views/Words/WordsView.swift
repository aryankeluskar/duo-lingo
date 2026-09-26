import SwiftUI

/// Every word in the deck. A star sends the word back into the deck until you clear it.
struct WordsView: View {
  @Environment(StudySession.self) private var session
  @Environment(\.cardStyle) private var style

  var body: some View {
    NavigationStack {
      List {
        Section {
          ForEach(session.deck) { word in
            WordRow(word: word)
          }
        } footer: {
          Text("Starred words come back for another look until you clear the star.")
        }
      }
      .navigationTitle("Japanese")
      .toolbarTitleDisplayMode(.inlineLarge)
    }
  }
}
