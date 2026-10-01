import SwiftData
import SwiftUI

/// The weekly goals on the home screen: rings plus a labelled legend with the numbers.
struct WeeklyGoalsCard: View {
  var track: ExamTrack
  @Environment(\.catalog) private var catalog
  @Query private var attempts: [Attempt]
  @AppStorage(WeeklyGoal.mathTasks.settingsKey) private var mathTarget = WeeklyGoal.mathTasks.defaultTarget
  @AppStorage(WeeklyGoal.languageTasks.settingsKey) private var languageTarget = WeeklyGoal.languageTasks.defaultTarget
  @AppStorage(WeeklyGoal.practiceDays.settingsKey) private var daysTarget = WeeklyGoal.practiceDays.defaultTarget
  @AppStorage(WeeklyGoal.essays.settingsKey) private var essayTarget = WeeklyGoal.essays.defaultTarget

  private func target(for goal: WeeklyGoal) -> Int {
    switch goal {
    case .mathTasks: mathTarget
    case .languageTasks: languageTarget
    case .practiceDays: daysTarget
    case .essays: essayTarget
    }
  }

  var body: some View {
    let values = WeeklyGoal.allCases.map { goal in
      GoalValue(goal: goal, done: goal.progress(attempts: attempts, catalog: catalog), target: target(for: goal))
    }
    let reachedCount = values.filter { $0.done >= $0.target }.count

    VStack(alignment: .leading, spacing: 14) {
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 20) {
          rings(values)
            .frame(width: 128, height: 128)
          legend(values)
        }
        VStack(alignment: .leading, spacing: 16) {
          rings(values)
            .frame(width: 160, height: 160)
            .frame(maxWidth: .infinity)
          legend(values)
        }
      }
      Text(message(reached: reachedCount, total: values.count))
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 6)
  }

  private func rings(_ values: [GoalValue]) -> some View {
    ActivityRings(rings: values.map { value in
      ActivityRing(id: value.goal.id, progress: Double(value.done) / Double(max(value.target, 1)), color: value.goal.color)
    })
  }

  private func legend(_ values: [GoalValue]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(values) { value in
        HStack(spacing: 8) {
          Circle()
            .fill(value.goal.color)
            .frame(width: 8, height: 8)
            .padding(3)
            .background(.black, in: .circle)
            .accessibilityHidden(true)
          Text(value.goal.title)
            .font(.subheadline)
          Spacer(minLength: 8)
          Text("\(value.done)/\(value.target)")
            .font(.subheadline.monospacedDigit())
            .foregroundStyle(.secondary)
          if value.done >= value.target {
            Image(systemName: "checkmark.circle.fill")
              .foregroundStyle(.green)
              .accessibilityLabel("erreicht")
          }
        }
        .accessibilityElement(children: .combine)
      }
    }
  }

  private func message(reached: Int, total: Int) -> String {
    if reached == total {
      return track.usesSimpleLanguage ? "Super, du hast alle Wochenziele erreicht!" : "Alle Wochenziele erreicht."
    }
    let calendar = Calendar.current
    let daysLeft = (calendar.dateInterval(of: .weekOfYear, for: .now)?.end).map {
      max(calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: $0).day ?? 0, 0)
    } ?? 0
    let left = daysLeft == 1 ? "Heute ist der letzte Tag dieser Woche." : "Noch \(daysLeft) Tage in dieser Woche."
    if reached == 0 {
      return track.usesSimpleLanguage ? "\(left) Schon eine Aufgabe bringt dich weiter." : left
    }
    return track.usesSimpleLanguage ? "\(reached) von \(total) Zielen geschafft. Weiter so! \(left)" : "\(reached) von \(total) Zielen erreicht. \(left)"
  }
}

private struct GoalValue: Identifiable {
  var goal: WeeklyGoal
  var done: Int
  var target: Int

  var id: WeeklyGoal { goal }
}
