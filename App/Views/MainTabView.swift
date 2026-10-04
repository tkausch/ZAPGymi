import SwiftData
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
  @Environment(\.modelContext) private var modelContext
  @Environment(\.catalog) private var catalog
  @Query private var attempts: [Attempt]
  @Query private var sessions: [ExamSession]
  @AppStorage(WeeklyGoal.mathTasks.settingsKey) private var mathTarget = WeeklyGoal.mathTasks.defaultTarget
  @AppStorage(WeeklyGoal.languageTasks.settingsKey) private var languageTarget = WeeklyGoal.languageTasks.defaultTarget
  @AppStorage(WeeklyGoal.practiceDays.settingsKey) private var daysTarget = WeeklyGoal.practiceDays.defaultTarget
  @AppStorage(WeeklyGoal.essays.settingsKey) private var essayTarget = WeeklyGoal.essays.defaultTarget
  @State private var celebration: [RewardNotice] = []
  @State private var toast: [RewardNotice] = []

  /// Changes whenever something happened that can earn stars.
  private var rewardTrigger: [Int] {
    [attempts.count, sessions.filter { $0.gradedAt != nil }.count, mathTarget, languageTarget, daysTarget, essayTarget]
  }

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
    .overlay(alignment: .top) {
      if !toast.isEmpty {
        RewardToast(notices: toast)
          .padding(.top, 8)
          .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
    .overlay {
      if !celebration.isEmpty {
        RewardCelebrationView(notices: celebration) {
          withAnimation(.smooth) { celebration = [] }
        }
        .transition(.opacity)
      }
    }
    .onChange(of: rewardTrigger, initial: true) {
      grantStars()
    }
  }

  private func grantStars() {
    let notices = RewardEngine.grantDueAwards(in: modelContext, catalog: catalog).map(RewardNotice.init)
    guard !notices.isEmpty else { return }
    // Small rewards are folded into a celebration that happens at the same time.
    if notices.contains(where: \.kind.isBigMoment) {
      withAnimation(.smooth) { celebration = celebration + notices }
    } else {
      withAnimation(.snappy) { toast = notices }
      Task {
        try? await Task.sleep(for: .seconds(2.5))
        withAnimation(.smooth) { toast = [] }
      }
    }
  }
}
