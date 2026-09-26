import SwiftUI

struct WordRow: View {
  var word: Word

  @Environment(StudySession.self) private var session
  @Environment(\.cardStyle) private var style

  var body: some View {
    let isStarred = session.isStarred(word)
    let isKnown = session.known.contains(word.id)
    HStack(spacing: 14) {
      VStack(alignment: .leading, spacing: 3) {
        // The note sits beside the term, or under it when a concept's name leaves no room.
        ViewThatFits(in: .horizontal) {
          HStack(alignment: .firstTextBaseline, spacing: 8) {
            term
            note
          }
          VStack(alignment: .leading, spacing: 2) {
            term
            note
          }
        }
        Text(word.meaning)
          .font(.system(size: 16, design: style.bodyDesign))
          .foregroundStyle(style.inkSecondary)
      }
      Spacer(minLength: 0)
      if isKnown {
        Image(systemName: "checkmark")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.tertiary)
          .accessibilityLabel("Known today")
      }
      Button {
        session.toggleStar(word)
      } label: {
        Label("Review Again", systemImage: isStarred ? "star.fill" : "star")
          .labelStyle(.iconOnly)
          .font(.title3)
          .foregroundStyle(isStarred ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
          .contentTransition(.symbolEffect(.replace))
          .frame(minWidth: 44, minHeight: 44)
      }
      .buttonStyle(.plain)
      .accessibilityAddTraits(isStarred ? .isSelected : [])
      .sensoryFeedback(.selection, trigger: isStarred)
    }
    .swipeActions {
      Button(isStarred ? "Clear Star" : "Review Again", systemImage: isStarred ? "star.slash" : "star") {
        session.toggleStar(word)
      }
      .tint(style.accent)
    }
  }

  private var term: some View {
    Text(word.spokenTerm)
      .font(.system(size: 22, weight: .semibold, design: style.wordDesign))
      .foregroundStyle(style.ink)
      .typesettingLanguage(word.deck.language)
      .fixedSize(horizontal: false, vertical: true)
  }

  private var note: some View {
    Text(word.spokenNote)
      .font(style.noteDesign == .monospaced ? .system(size: 11, weight: .medium, design: .monospaced) : .subheadline)
      .textCase(style.noteDesign == .monospaced ? .uppercase : nil)
      .tracking(style.noteDesign == .monospaced ? 1.6 : 0)
      .foregroundStyle(style.noteInk ?? .secondary)
      .typesettingLanguage(word.deck.language)
      .lineLimit(1)
  }
}
