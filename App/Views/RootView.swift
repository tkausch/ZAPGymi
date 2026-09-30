import SwiftUI

struct RootView: View {
  @AppStorage(SettingsKey.track) private var trackRaw = ""

  var body: some View {
    if let track = ExamTrack(rawValue: trackRaw) {
      MainTabView(track: track)
    } else {
      OnboardingView { trackRaw = $0.rawValue }
    }
  }
}
