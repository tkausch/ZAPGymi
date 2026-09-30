import SwiftUI

struct RootView: View {
  @AppStorage(SettingsKey.track) private var trackRaw = ""
  @AppStorage(SettingsKey.theme) private var themeRaw = AppTheme.standard.rawValue
  @AppStorage(SettingsKey.appearance) private var appearanceRaw = AppearanceMode.automatic.rawValue

  private var theme: AppTheme {
    AppTheme(rawValue: themeRaw) ?? .standard
  }

  var body: some View {
    Group {
      if let track = ExamTrack(rawValue: trackRaw) {
        MainTabView(track: track)
      } else {
        OnboardingView { track, theme in
          themeRaw = theme.rawValue
          trackRaw = track.rawValue
        }
      }
    }
    .environment(\.appTheme, theme)
    .tint(theme.accent)
    .onChange(of: appearanceRaw, initial: true) {
      (AppearanceMode(rawValue: appearanceRaw) ?? .automatic).apply()
    }
  }
}
