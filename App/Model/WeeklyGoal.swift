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

  /// The Apple Watch activity ring colours (Move, Exercise, Stand) plus yellow for the fourth ring.
  /// They are made for a black background, so rings and colour markers always sit on black:
  /// contrast there is 4.3:1 to 15:1, and neighbouring rings stay distinguishable with colour blindness.
  var color: Color {
    switch self {
    case .mathTasks: Color(light: 0xFA114F, dark: 0xFA114F)
    case .languageTasks: Color(light: 0x92E82A, dark: 0x92E82A)
    case .practiceDays: Color(light: 0x1EEAEF, dark: 0x1EEAEF)
    case .essays: Color(light: 0xFFD60A, dark: 0xFFD60A)
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
