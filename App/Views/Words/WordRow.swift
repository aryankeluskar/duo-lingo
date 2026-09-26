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
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(word.spokenTerm)
            .font(.system(size: 22, weight: .semibold, design: style.wordDesign))
            .typesettingLanguage(word.deck.language)
          Text(word.spokenNote)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .typesettingLanguage(word.deck.language)
        }
        Text(word.meaning)
          .font(.system(size: 15))
          .foregroundStyle(.secondary)
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
}
