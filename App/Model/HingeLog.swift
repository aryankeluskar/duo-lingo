#if DEBUG
import Foundation

/// Appends every hinge update to Library/Caches/hinge-log.txt, to measure how often
/// the system reports the angle while the device is partially open.
enum HingeLog {
  static func record(_ state: FoldState) {
    let posture = state.posture?.rawValue ?? "none"
    let angle = state.angle.map { String(format: "%.1f", $0.degrees) } ?? "-"
    let line = String(format: "%.3f", Date.now.timeIntervalSince1970) + " \(posture) \(angle)\n"
    let url = URL.cachesDirectory.appending(path: "hinge-log.txt")
    if let handle = try? FileHandle(forWritingTo: url) {
      handle.seekToEndOfFile()
      handle.write(Data(line.utf8))
      try? handle.close()
    } else {
      try? Data(line.utf8).write(to: url)
    }
  }
}
#endif
