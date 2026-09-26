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

  /// How far the pages have come apart, from 0 with them together to 1 once they stand at
  /// about a right angle and read like a book. Nil lying flat or without a hinge.
  var openingProgress: Double? {
    guard let angle, posture != .fullyOpen else { return nil }
    return min(max((angle.degrees - 25) / 65, 0), 1)
  }

  /// How sharply the display bends at the fold, from 0 lying flat to 1 at a right angle.
  var foldDepth: Double {
    guard let angle, posture != .fullyOpen else { return 0 }
    return min(max((180 - angle.degrees) / 90, 0), 1)
  }

  #if DEBUG
  /// A fixed pose for screenshots, from the `-hingeAngle` launch argument, in place of the hinge.
  static var debugPose: FoldState? {
    let defaults = UserDefaults.standard
    guard defaults.object(forKey: "hingeAngle") != nil else { return nil }
    let degrees = defaults.double(forKey: "hingeAngle")
    return FoldState(posture: degrees >= 180 ? .fullyOpen : .partiallyOpen, angle: .degrees(degrees))
  }
  #endif
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
