import SwiftUI

/// Keys for the settings stored in UserDefaults.
enum SettingsKey {
  static let track = "examTrack"
  static let examDate = "examDate"
}

extension EnvironmentValues {
  @Entry var catalog: Catalog = .empty
}
