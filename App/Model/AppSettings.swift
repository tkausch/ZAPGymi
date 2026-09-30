import SwiftUI

/// Keys for the settings stored in UserDefaults.
enum SettingsKey {
  static let track = "examTrack"
  static let examDate = "examDate"
  static let theme = "appTheme"
  static let appearance = "appearanceMode"
}

extension EnvironmentValues {
  @Entry var catalog: Catalog = .empty
  @Entry var appTheme: AppTheme = .standard
}
