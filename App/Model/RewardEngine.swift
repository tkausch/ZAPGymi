import Foundation
import SwiftData

/// Works out which stars are due and pays them out exactly once.
enum RewardEngine {
  private static let initializedKey = "rewards.initialized"

  /// Inserts all due awards and returns the new ones the child should see.
  /// The first run after installing or updating pays out earlier achievements quietly.
  @MainActor
  static func grantDueAwards(in context: ModelContext, catalog: Catalog, now: Date = .now) -> [StarAward] {
    let attempts = (try? context.fetch(FetchDescriptor<Attempt>(sortBy: [SortDescriptor(\.date)]))) ?? []
    let sessions = (try? context.fetch(FetchDescriptor<ExamSession>())) ?? []
    let existingKeys = Set(((try? context.fetch(FetchDescriptor<StarAward>())) ?? []).map(\.key))

    let newAwards = dueAwards(attempts: attempts, sessions: sessions, catalog: catalog, now: now)
      .filter { !existingKeys.contains($0.key) }
    newAwards.forEach(context.insert)

    let defaults = UserDefaults.standard
    guard defaults.bool(forKey: initializedKey) else {
      defaults.set(true, forKey: initializedKey)
      unlockStartTheme(in: context)
      try? context.save()
      return []
    }
    if !newAwards.isEmpty {
      try? context.save()
    }
    return newAwards
  }

  /// Forgets that rewards were set up, used when all data is deleted.
  static func reset() {
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: initializedKey)
    for slot in [MascotAccessory.Slot.head, .face] {
      defaults.removeObject(forKey: slot.settingsKey)
    }
  }

  /// Unlocks an extra and takes the stars.
  @MainActor
  static func unlock(_ item: RewardItem, in context: ModelContext) {
    context.insert(UnlockedReward(itemID: item.id, cost: item.cost))
    try? context.save()
  }

  /// The theme chosen at the start is a gift.
  @MainActor
  private static func unlockStartTheme(in context: ModelContext) {
    let raw = UserDefaults.standard.string(forKey: SettingsKey.theme) ?? ""
    guard let theme = AppTheme(rawValue: raw), theme.starCost > 0 else { return }
    let itemID = RewardItem.theme(theme).id
    let existing = (try? context.fetch(FetchDescriptor<UnlockedReward>(predicate: #Predicate { $0.itemID == itemID }))) ?? []
    if existing.isEmpty {
      context.insert(UnlockedReward(itemID: itemID, cost: 0))
    }
  }

  /// Every award the history earns, whether paid out already or not.
  static func dueAwards(
    attempts: [Attempt],
    sessions: [ExamSession],
    catalog: Catalog,
    calendar: Calendar = .current,
    now: Date = .now
  ) -> [StarAward] {
    var awards: [StarAward] = []

    // Rings of the current week. Past weeks were paid out while they were current.
    if let week = calendar.dateInterval(of: .weekOfYear, for: now) {
      let weekKey = Int(week.start.timeIntervalSinceReferenceDate)
      var closedCount = 0
      for goal in WeeklyGoal.allCases {
        let target = goal.currentTarget
        guard target >= goal.rewardMinimum,
              goal.progress(attempts: attempts, catalog: catalog, calendar: calendar, now: now) >= target
        else { continue }
        closedCount += 1
        awards.append(StarAward(
          key: "ring.\(goal.rawValue).\(weekKey)",
          kind: .ringClosed,
          stars: RewardKind.ringClosed.stars,
          title: "Ring «\(goal.title)» geschlossen"
        ))
      }
      if closedCount == WeeklyGoal.allCases.count {
        awards.append(StarAward(
          key: "allRings.\(weekKey)",
          kind: .allRings,
          stars: RewardKind.allRings.stars,
          title: "Alle Wochenringe geschlossen"
        ))
      }
    }

    for session in sessions where session.state == .graded {
      awards.append(StarAward(
        key: "exam.\(session.id.uuidString)",
        kind: .examSimulation,
        stars: RewardKind.examSimulation.stars,
        title: "Probeprüfung \(session.subject.title) \(String(session.year))",
        date: session.gradedAt ?? now
      ))
    }

    // Practising a task again after a mistake pays out once per task and day.
    var lastOutcome: [String: Outcome] = [:]
    var seenKeys: Set<String> = []
    for attempt in attempts.sorted(by: { $0.date < $1.date }) {
      defer { lastOutcome[attempt.taskID] = attempt.outcome }
      guard let previous = lastOutcome[attempt.taskID], previous != .richtig else { continue }
      let day = Int(calendar.startOfDay(for: attempt.date).timeIntervalSinceReferenceDate)
      let taskTitle = catalog.task(id: attempt.taskID)?.displayTitle ?? "Aufgabe"
      let repeatKey = "mistake.repeat.\(attempt.taskID).\(day)"
      if seenKeys.insert(repeatKey).inserted {
        awards.append(StarAward(
          key: repeatKey,
          kind: .mistakeRepeated,
          stars: RewardKind.mistakeRepeated.stars,
          title: "Fehler wiederholt: \(taskTitle)",
          date: attempt.date
        ))
      }
      let fixKey = "mistake.fixed.\(attempt.taskID).\(day)"
      if attempt.outcome == .richtig, seenKeys.insert(fixKey).inserted {
        awards.append(StarAward(
          key: fixKey,
          kind: .mistakeFixed,
          stars: RewardKind.mistakeFixed.stars,
          title: "Fehler korrigiert: \(taskTitle)",
          date: attempt.date
        ))
      }
    }

    return awards
  }
}
