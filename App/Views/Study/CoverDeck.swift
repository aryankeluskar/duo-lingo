import SwiftUI

/// The deck on the cover display and on other iPhones. Tapping reveals the answer; putting a
/// card away deals it off the top of the deck onto the next one.
struct CoverDeck: View {
  @Environment(StudySession.self) private var session
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.cardStyle) private var style

  private var isSheet: Bool {
    style.surface == .paper
  }

  var body: some View {
    ZStack {
      ForEach(Array(session.queue.prefix(2).enumerated()), id: \.element.id) { index, card in
        let isTop = index == 0
        CoverCard(word: card.word, seed: card.id, isRevealed: isTop && session.isRevealed, action: tapTopCard)
          .disabled(!isTop)
          .accessibilityHidden(!isTop)
          // Sheets of paper lie flat in a stack; cards sit back a little beneath the top one.
          .scaleEffect(isTop || isSheet ? 1 : 0.94)
          // Glass is translucent, so the card beneath stays hidden until it's dealt.
          .opacity(isTop || isSheet ? 1 : 0)
          // Earlier cards sit higher, so a card being dealt away stays above the one beneath it.
          .zIndex(-Double(card.id))
          .transition(DealOffTransition(reduceMotion: reduceMotion))
      }
    }
    .task(id: session.isDealPending) {
      guard session.isDealPending else { return }
      // Let the cover wake with the finished card in place, then deal it away.
      try? await Task.sleep(for: .milliseconds(350))
      withAnimation(.smooth(duration: 0.55)) {
        session.dealIfPending()
      }
    }
  }

  private func tapTopCard() {
    if session.isRevealed {
      withAnimation(.smooth(duration: 0.55)) {
        session.advance()
      }
    } else {
      session.reveal()
    }
  }
}

/// A single card: the word, which gives way to the answer once revealed.
private struct CoverCard: View {
  var word: Word
  var seed: Int
  var isRevealed: Bool
  var action: () -> Void

  @Environment(\.cardStyle) private var style

  var body: some View {
    Button(action: action) {
      ZStack {
        QuestionContent(word: word)
          .opacity(isRevealed ? 0 : 1)
          .blur(radius: isRevealed ? 8 : 0)
          .animation(.smooth(duration: 0.35), value: isRevealed)
          .accessibilityHidden(isRevealed)
        AnswerContent(word: word, isRevealed: isRevealed, showsTerm: true)
          .padding(.horizontal, 32)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background {
        Surface(isOpaque: true, seed: seed)
      }
      .contentShape(.rect(cornerRadius: style.cornerRadius, style: .continuous))
    }
    .buttonStyle(CardPressStyle())
    .keyboardShortcut(.space, modifiers: [])
    .accessibilityHint(isRevealed ? "Puts this card away" : "Reveals the answer")
  }
}

/// The top card slides off the deck to the leading side, tipping as it goes.
private struct DealOffTransition: Transition {
  var reduceMotion: Bool

  func body(content: Content, phase: TransitionPhase) -> some View {
    let isLeaving = phase == .didDisappear
    if reduceMotion {
      content.opacity(isLeaving ? 0 : 1)
    } else {
      content.visualEffect { effect, proxy in
        effect
          .rotationEffect(.degrees(isLeaving ? -8 : 0), anchor: .bottom)
          .offset(x: isLeaving ? -proxy.size.width * 1.15 : 0, y: isLeaving ? -16 : 0)
      }
    }
  }
}
