import SwiftUI

/// Reports the hinge on iPhone Duo. Does nothing on earlier systems.
struct HingeTracking: ViewModifier {
  var action: (FoldState) -> Void

  func body(content: Content) -> some View {
    if #available(iOS 27.1, *) {
      content.onHingeChange { _, context in
        action(FoldState(context))
      }
    } else {
      content
    }
  }
}
