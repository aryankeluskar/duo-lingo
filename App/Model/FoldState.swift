import SwiftUI

/// The hinge as last reported by the system. `posture` stays nil on devices without a hinge.
struct FoldState: Equatable {
  enum Posture: String, Equatable {
    case closed
    case partiallyOpen
    case fullyOpen
  }

  var posture: Posture?
  var angle: Angle?

  var hasHinge: Bool { posture != nil }
}

@available(iOS 27.1, *)
extension FoldState {
  init(_ context: DeviceHingeContext) {
    guard let hinge = context.hinge else {
      self.init()
      return
    }
    let posture: Posture =
      if hinge.status == .closed {
        .closed
      } else if hinge.status == .partiallyOpen {
        .partiallyOpen
      } else {
        .fullyOpen
      }
    self.init(posture: posture, angle: hinge.angle)
  }
}
