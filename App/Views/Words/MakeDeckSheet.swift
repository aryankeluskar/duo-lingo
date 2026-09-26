import SwiftUI

/// Paste any link, and OpenAI reads the page and writes the cards worth remembering from it.
struct MakeDeckSheet: View {
  @Environment(StudySession.self) private var session
  @Environment(\.cardStyle) private var style
  @Environment(\.dismiss) private var dismiss
  @State private var link = ""
  @State private var key = ""
  @State private var isWorking = false
  @State private var failure: String?
  @FocusState private var isLinkFocused: Bool

  private let needsKey = CardMaker.apiKey == nil

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("https://", text: $link)
            .keyboardType(.URL)
            .textContentType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isLinkFocused)
            .submitLabel(.go)
            .onSubmit(make)
            .listRowBackground(style.listPaper?.row)
        } header: {
          Text("Link")
        } footer: {
          Text("An article, lecture notes, a vocabulary list: anything worth remembering. OpenAI picks the ideas that matter and writes a card for each.")
        }
        if needsKey {
          Section("OpenAI API Key") {
            SecureField("sk-…", text: $key)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
              .listRowBackground(style.listPaper?.row)
          }
        }
        Section {
          Button(action: make) {
            HStack(spacing: 10) {
              if isWorking {
                ProgressView()
              }
              Text(isWorking ? "Writing cards…" : "Make Cards")
                .font(.system(size: 17, weight: .semibold, design: style.bodyDesign))
            }
            .frame(maxWidth: .infinity)
          }
          .disabled(isWorking || url == nil || (needsKey && key.isEmpty))
          .listRowBackground(style.listPaper?.row)
        } footer: {
          if let failure {
            Text(failure)
              .foregroundStyle(.red)
          }
        }
      }
      .scrollContentBackground(style.listPaper == nil ? .automatic : .hidden)
      .background(style.listPaper?.sheet ?? .clear)
      .navigationTitle("New Deck")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel) { dismiss() }
        }
      }
      .onAppear {
        if let pasted = UIPasteboard.general.hasURLs ? UIPasteboard.general.url : nil {
          link = pasted.absoluteString
        } else {
          isLinkFocused = true
        }
      }
    }
    .presentationDetents([.medium, .large])
    .interactiveDismissDisabled(isWorking)
  }

  private var url: URL? {
    var text = link.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else { return nil }
    if !text.contains("://") {
      text = "https://" + text
    }
    guard let url = URL(string: text), url.host() != nil else { return nil }
    return url
  }

  private func make() {
    guard let url, !isWorking else { return }
    if needsKey {
      CardMaker.apiKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    isWorking = true
    failure = nil
    Task {
      do {
        let contents = try await CardMaker.makeDeck(from: url)
        WebDeck.shared.replace(with: contents)
        withAnimation(.smooth) {
          session.studyWebDeck()
        }
        dismiss()
      } catch {
        failure = error.localizedDescription
      }
      isWorking = false
    }
  }
}
