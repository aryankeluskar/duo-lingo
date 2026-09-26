import SwiftUI

/// Every word in the deck, with the deck picker on top. A star sends the word back into the
/// deck until you clear it.
struct WordsView: View {
  @Environment(StudySession.self) private var session

  var body: some View {
    NavigationStack {
      List {
        Section {
          Picker("Language", selection: deckSelection) {
            ForEach(Deck.allCases) { deck in
              Text(deck.nativeName).tag(deck)
            }
          }
          .pickerStyle(.segmented)
          .listRowInsets(EdgeInsets())
          .listRowBackground(Color.clear)
        }
        Section {
          ForEach(session.words) { word in
            WordRow(word: word)
          }
        } footer: {
          Text("Starred words come back for another look until you clear the star.")
        }
      }
      .navigationTitle(Text(session.deck.name))
      .toolbarTitleDisplayMode(.inlineLarge)
    }
  }

  private var deckSelection: Binding<Deck> {
    Binding {
      session.deck
    } set: { deck in
      withAnimation(.smooth) {
        session.selectDeck(deck)
      }
    }
  }
}
