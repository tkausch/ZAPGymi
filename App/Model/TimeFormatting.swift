import Foundation

enum TimeFormatting {
  /// Formats a countdown like "59:12" or "1:29:12".
  static func clock(_ seconds: Double) -> String {
    let duration = Duration.seconds(max(0, seconds.rounded(.up)))
    return seconds >= 3600
      ? duration.formatted(.time(pattern: .hourMinuteSecond))
      : duration.formatted(.time(pattern: .minuteSecond))
  }

  /// Formats a length like "45 Min.".
  static func minutes(_ seconds: Double) -> String {
    "\(Int((seconds / 60).rounded())) Min."
  }
}
