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
          Spine(axis: spine.axis)
          if spine.axis == .horizontal {
            answerPage
            questionPage
          } else {
            questionPage
            answerPage
          }
        }
      }
      .clipShape(.rect(cornerRadius: style.cornerRadius, style: .continuous))
      .background {
        PaperSurface()
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
  private var answerPage: some View {
    ZStack {
      AnswerContent(word: card.word, isRevealed: session.isRevealed, restingOpacity: 0.12)
        .padding(.horizontal, 40)
        .id(card.id)
        .transition(.blurReplace)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var questionPage: some View {
    ZStack {
      QuestionContent(word: card.word)
        .id(card.id)
        .transition(.blurReplace)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
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

/// The binding between the pages: a hairline, a soft crease, or both, depending on the style.
private struct Spine: View {
  var axis: Axis

  @Environment(\.cardStyle) private var style
  @Environment(\.displayScale) private var displayScale

  var body: some View {
    let isVertical = axis == .horizontal
    ZStack {
      LinearGradient(
        stops: [
          .init(color: style.creaseShadow.opacity(0), location: 0),
          .init(color: style.creaseShadow.opacity(0.3), location: 0.28),
          .init(color: style.creaseShadow, location: 0.47),
          .init(color: style.creaseHighlight, location: 0.54),
          .init(color: style.creaseShadow.opacity(0.12), location: 0.64),
          .init(color: style.creaseShadow.opacity(0), location: 1),
        ],
        startPoint: isVertical ? .leading : .top,
        endPoint: isVertical ? .trailing : .bottom
      )
      .frame(width: isVertical ? 84 : nil, height: isVertical ? nil : 84)
      if style.showsSpineRule {
        Rectangle()
          .fill(style.rule)
          .frame(width: isVertical ? 1 / displayScale : nil, height: isVertical ? nil : 1 / displayScale)
          .padding(isVertical ? .vertical : .horizontal, 22)
      }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}
