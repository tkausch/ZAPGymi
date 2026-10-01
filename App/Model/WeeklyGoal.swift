import SwiftUI

/// One of the weekly goals, shown as a ring like the Apple Watch activity rings.
enum WeeklyGoal: String, CaseIterable, Identifiable {
  case mathTasks
  case languageTasks
  case practiceDays
  case essays

  var id: String { rawValue }

  var title: String {
    switch self {
    case .mathTasks: "Mathe-Aufgaben"
    case .languageTasks: "Deutsch-Aufgaben"
    case .practiceDays: "Übungstage"
    case .essays: "Aufsätze"
    }
  }

  var systemImage: String {
    switch self {
    case .mathTasks: "function"
    case .languageTasks: "text.book.closed"
    case .practiceDays: "calendar"
    case .essays: "pencil.line"
    }
  }

  /// Key for the target in UserDefaults.
  var settingsKey: String { "weeklyGoal.\(rawValue)" }

  var defaultTarget: Int {
    switch self {
    case .mathTasks: 10
    case .languageTasks: 5
    case .practiceDays: 4
    case .essays: 1
    }
  }

  var range: ClosedRange<Int> {
    switch self {
    case .mathTasks: 1...50
    case .languageTasks: 1...30
    case .practiceDays: 1...7
    case .essays: 1...5
    }
  }

  /// Ring colours in fixed order from the outside in. Neighbouring rings stay distinguishable
  /// with colour blindness (checked with the OKLab/CVD validator); every ring is also labelled with text.
  var color: Color {
    switch self {
    case .mathTasks: Color(light: 0x2A78D6, dark: 0x3987E5)
    case .languageTasks: Color(light: 0xEB6834, dark: 0xD95926)
    case .practiceDays: Color(light: 0x1BAF7A, dark: 0x199E70)
    case .essays: Color(light: 0xEDA100, dark: 0xC98500)
    }
  }

  /// What counts towards the goal in the current week.
  func progress(attempts: [Attempt], catalog: Catalog, calendar: Calendar = .current, now: Date = .now) -> Int {
    guard let week = calendar.dateInterval(of: .weekOfYear, for: now) else { return 0 }
    let thisWeek = attempts.filter { week.contains($0.date) }
    switch self {
    case .practiceDays:
      return Set(thisWeek.map { calendar.startOfDay(for: $0.date) }).count
    case .mathTasks, .languageTasks, .essays:
      let subject: Subject = self == .mathTasks ? .mathematik : (self == .languageTasks ? .sprache : .aufsatz)
      // Each task counts once per week, even if it was practised several times.
      let taskIDs = Set(thisWeek.map(\.taskID))
      return taskIDs.filter { catalog.task(id: $0)?.subject == subject }.count
    }
  }
}
