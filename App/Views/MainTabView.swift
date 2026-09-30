import SwiftUI

enum AppTab: Hashable {
  case today
  case tasks
  case exam
  case progress
  case tips
}

struct MainTabView: View {
  var track: ExamTrack
  @State private var selectedTab = AppTab.today

  var body: some View {
    TabView(selection: $selectedTab) {
      Tab("Heute", systemImage: "house", value: .today) {
        HomeView(track: track, selectedTab: $selectedTab)
      }
      Tab("Aufgaben", systemImage: "list.bullet.rectangle", value: .tasks) {
        CatalogView(track: track)
      }
      Tab("Prüfung", systemImage: "timer", value: .exam) {
        SimulationHomeView(track: track)
      }
      Tab("Fortschritt", systemImage: "chart.bar", value: .progress) {
        ProgressOverviewView(track: track, selectedTab: $selectedTab)
      }
      Tab("Tipps", systemImage: "lightbulb", value: .tips) {
        TipsView(track: track)
      }
    }
  }
}
