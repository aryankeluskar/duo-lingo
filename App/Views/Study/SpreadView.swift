import SwiftUI

/// The open book on the inner display: the answer page on the leading side and the question
/// page on the trailing side, bound by a spine that sits on the hinge. In the table pose the
/// question takes the upright top half and the answer the bottom.
struct SpreadView: View {
  var card: StudySession.Card

  @Environment(StudySession.self) private var session
  @Environment(\.cardStyle) private var style

  var body: some View {
    Button(action: tap) {
      GeometryReader { proxy in
        let spine = SpineLocation(proxy)
        PageSpreadLayout(spine: spine) {
          Color.clear
          if spine.axis == .horizontal {
            // Side by side, both pages hang from one horizon line across the fold.
            let alignment = Alignment(horizontal: .center, vertical: .horizon)
            answerPage(alignment: alignment)
            questionPage(alignment: alignment)
          } else {
            questionPage(alignment: .center)
            answerPage(alignment: .center)
          }
        }
      }
      .background {
        Surface()
      }
      .contentShape(.rect(cornerRadius: style.cornerRadius, style: .continuous))
    }
    .buttonStyle(CardPressStyle())
    .keyboardShortcut(.space, modifiers: [])
    .accessibilityHint(session.isRevealed ? "" : "Reveals the answer")
    .accessibilityAction(named: "Next Card") {
      withAnimation(.smooth(duration: 0.5)) {
        session.advance()
      }
    }
  }

  // Each page is a container, so the layout keeps exactly three children while one card
  // gives way to the next inside it.
  private func answerPage(alignment: Alignment) -> some View {
    ZStack(alignment: alignment) {
      AnswerContent(
        word: card.word,
        isRevealed: session.isRevealed,
        openingProgress: session.fold.openingProgress
      )
        .padding(.horizontal, 52)
        .id(card.id)
        .transition(.blurReplace)
      Text("Fold, recall, unfold.")
        .font(.system(size: 17, weight: .medium))
        .foregroundStyle(style.inkTertiary)
        .alignmentGuide(.horizon) { $0[.lastTextBaseline] }
        .opacity(session.isRevealed ? 0 : 1)
        .blur(radius: session.isRevealed ? 6 : 0)
        .animation(.smooth(duration: 0.3), value: session.isRevealed)
        .accessibilityHidden(true)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
  }

  private func questionPage(alignment: Alignment) -> some View {
    ZStack(alignment: alignment) {
      QuestionContent(word: card.word)
        .id(card.id)
        .transition(.blurReplace)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
  }

  /// Tapping reveals a veiled answer. With no hinge to fold, a second tap moves on.
  private func tap() {
    if !session.isRevealed {
      session.reveal()
    } else if !session.fold.hasHinge {
      withAnimation(.smooth(duration: 0.5)) {
        session.advance()
      }
    }
  }
}

/// Where the spine falls: on the fold when the display has one, otherwise in the middle.
private struct SpineLocation: Equatable {
  /// The axis the two pages sit along.
  var axis: Axis
  /// The spine's center along `axis`, in the spread's own coordinates.
  var position: CGFloat
  /// The space kept clear around the spine.
  var gutter: CGFloat

  init(_ proxy: GeometryProxy) {
    let size = proxy.size
    if #available(iOS 27.1, *),
      let fold = proxy.reservedRegions(kind: .division, options: .includeInactive).first
    {
      let frame = fold.frame
      let margins = fold.margins
      if frame.height >= frame.width {
        axis = .horizontal
        position = frame.midX
        gutter = max(Self.minimumGutter, frame.width + margins.leading + margins.trailing)
      } else {
        axis = .vertical
        position = frame.midY
        gutter = max(Self.minimumGutter, frame.height + margins.top + margins.bottom)
      }
    } else {
      axis = size.width >= size.height ? .horizontal : .vertical
      position = (axis == .horizontal ? size.width : size.height) / 2
      gutter = Self.minimumGutter
    }
    // A fold outside the middle of the spread (in Split View, say) isn't this spread's spine.
    let length = axis == .horizontal ? size.width : size.height
    if position < length * 0.3 || position > length * 0.7 {
      position = length / 2
    }
  }

  private static let minimumGutter: CGFloat = 40
}

/// Lays out the spine and the two pages on either side of it.
private struct PageSpreadLayout: Layout {
  var spine: SpineLocation

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    proposal.replacingUnspecifiedDimensions()
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    guard subviews.count == 3 else { return }
    let half = spine.gutter / 2
    let spineRect: CGRect
    let first: CGRect
    let second: CGRect
    switch spine.axis {
    case .horizontal:
      let x = bounds.minX + spine.position
      spineRect = CGRect(x: x - half, y: bounds.minY, width: spine.gutter, height: bounds.height)
      first = CGRect(x: bounds.minX, y: bounds.minY, width: x - half - bounds.minX, height: bounds.height)
      second = CGRect(x: x + half, y: bounds.minY, width: bounds.maxX - x - half, height: bounds.height)
    case .vertical:
      let y = bounds.minY + spine.position
      spineRect = CGRect(x: bounds.minX, y: y - half, width: bounds.width, height: spine.gutter)
      first = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: y - half - bounds.minY)
      second = CGRect(x: bounds.minX, y: y + half, width: bounds.width, height: bounds.maxY - y - half)
    }
    for (subview, rect) in zip(subviews, [spineRect, first, second]) {
      subview.place(at: CGPoint(x: rect.midX, y: rect.midY), anchor: .center, proposal: ProposedViewSize(rect.size))
    }
  }
}
