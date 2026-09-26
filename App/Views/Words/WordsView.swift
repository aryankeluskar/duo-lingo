import SwiftUI

/// Every card in the deck, with the deck shelf on top. A star sends the word back into the
/// deck until you clear it.
struct WordsView: View {
  @Environment(StudySession.self) private var session
  @Environment(\.cardStyle) private var style
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var isMakingDeck = false

  var body: some View {
    if horizontalSizeClass == .regular {
      // The inner display shows one more level of hierarchy: the decks beside their cards,
      // in a split view that keeps each column clear of the fold.
      NavigationSplitView {
        List(selection: deckListSelection) {
          ForEach(Deck.Subject.stocked) { subject in
            Section {
              ForEach(subject.decks) { deck in
                DeckRow(deck: deck)
                  .tag(deck)
                  .listRowBackground(deck == session.deck ? style.listPaper?.row : nil)
              }
            } header: {
              Text(subject.name)
            }
          }
        }
        .scrollContentBackground(style.listPaper == nil ? .automatic : .hidden)
        .background(style.listPaper?.sheet ?? .clear)
        .navigationTitle("Decks")
      } detail: {
        NavigationStack {
          wordList(showsShelf: false)
        }
      }
    } else {
      NavigationStack {
        wordList(showsShelf: true)
      }
    }
  }

  private func wordList(showsShelf: Bool) -> some View {
    List {
      if showsShelf {
        Section {
          DeckShelf(selection: deckSelection)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
      }
      Section {
        ForEach(session.words) { word in
          WordRow(word: word)
            .listRowBackground(style.listPaper?.row)
        }
      } footer: {
        Text("Starred words come back for another look until you clear the star.")
      }
    }
    .scrollContentBackground(style.listPaper == nil ? .automatic : .hidden)
    .background(style.listPaper?.sheet ?? .clear)
    .navigationTitle(Text(session.deck.name))
    .toolbarTitleDisplayMode(.inlineLarge)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Make a Deck from a Link", systemImage: "link.badge.plus") {
          isMakingDeck = true
        }
      }
    }
    .sheet(isPresented: $isMakingDeck) {
      MakeDeckSheet()
        .environment(session)
        .environment(\.cardStyle, style)
    }
  }

  private var deckListSelection: Binding<Deck?> {
    Binding {
      session.deck
    } set: { deck in
      if let deck {
        deckSelection.wrappedValue = deck
      }
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

/// A deck in the inner display's sidebar: its name, and how many of its cards are known today.
private struct DeckRow: View {
  var deck: Deck

  @Environment(StudySession.self) private var session
  @Environment(\.cardStyle) private var style

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(deck.nativeName)
        .font(.system(size: 17, design: style.bodyDesign))
        .typesettingLanguage(deck.language)
        .foregroundStyle(style.ink)
      Spacer()
      Text("\(deck.words.count)")
        .font(.system(size: 12, design: .monospaced))
        .foregroundStyle(style.noteInk ?? .secondary)
    }
  }
}

/// Every deck, shelved by subject and set like a printed index: a small caps heading over each
/// shelf, and the chosen deck printed solid.
private struct DeckShelf: View {
  @Binding var selection: Deck

  @Environment(\.cardStyle) private var style

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal) {
      HStack(alignment: .top, spacing: 22) {
        ForEach(Deck.Subject.stocked) { subject in
          VStack(alignment: .leading, spacing: 8) {
            Text(subject.name)
              .font(.system(size: 11, weight: .medium, design: .monospaced))
              .textCase(.uppercase)
              .tracking(1.6)
              .foregroundStyle(style.noteInk ?? .secondary)
              .accessibilityAddTraits(.isHeader)
            HStack(spacing: 6) {
              ForEach(subject.decks) { deck in
                chip(deck)
                  .id(deck)
              }
            }
          }
        }
      }
      .padding(.vertical, 4)
      .padding(.horizontal, 2)
      }
      .scrollIndicators(.hidden)
      .scrollClipDisabled()
      .onAppear {
        proxy.scrollTo(selection, anchor: .center)
      }
    }
  }

  private func chip(_ deck: Deck) -> some View {
    let isSelected = deck == selection
    let shape = RoundedRectangle(cornerRadius: style.cornerRadius == 0 ? 1 : 100, style: .continuous)
    return Button {
      selection = deck
    } label: {
      Text(deck.nativeName)
        .font(.system(size: 15, weight: .medium, design: style.bodyDesign))
        .typesettingLanguage(deck.language)
        .foregroundStyle(isSelected ? (style.listPaper?.sheet ?? Color(.systemBackground)) : style.ink)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background {
          if isSelected {
            shape.fill(style.ink).risoInk(style.isPrint, seed: 29)
          } else {
            shape.strokeBorder(style.inkTertiary, lineWidth: 1)
          }
        }
        .contentShape(shape)
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .sensoryFeedback(.selection, trigger: isSelected)
  }
}
