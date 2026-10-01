import SwiftUI

/// Lets the child set the weekly targets.
struct WeeklyGoalsSheet: View {
  @Environment(\.dismiss) private var dismiss
  @AppStorage(WeeklyGoal.mathTasks.settingsKey) private var mathTarget = WeeklyGoal.mathTasks.defaultTarget
  @AppStorage(WeeklyGoal.languageTasks.settingsKey) private var languageTarget = WeeklyGoal.languageTasks.defaultTarget
  @AppStorage(WeeklyGoal.practiceDays.settingsKey) private var daysTarget = WeeklyGoal.practiceDays.defaultTarget
  @AppStorage(WeeklyGoal.essays.settingsKey) private var essayTarget = WeeklyGoal.essays.defaultTarget

  var body: some View {
    NavigationStack {
      Form {
        Section {
          stepper(.mathTasks, value: $mathTarget, unit: "Aufgaben")
          stepper(.languageTasks, value: $languageTarget, unit: "Aufgaben")
          stepper(.practiceDays, value: $daysTarget, unit: "Tage")
          stepper(.essays, value: $essayTarget, unit: essayUnit)
        } header: {
          Text("Pro Woche")
        } footer: {
          Text("Eine Aufgabe zählt, sobald du dich eingeschätzt hast, pro Woche einmal. Ein Aufsatz zählt nach der Einschätzung mit der Checkliste. Ein Übungstag ist jeder Tag mit mindestens einer eingeschätzten Aufgabe. Die Woche beginnt am Montag.")
        }

        Section {
          Button("Standardwerte") {
            mathTarget = WeeklyGoal.mathTasks.defaultTarget
            languageTarget = WeeklyGoal.languageTasks.defaultTarget
            daysTarget = WeeklyGoal.practiceDays.defaultTarget
            essayTarget = WeeklyGoal.essays.defaultTarget
          }
        }
      }
      .themedBackground()
      .navigationTitle("Wochenziele")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Fertig") { dismiss() }
        }
      }
    }
  }

  private var essayUnit: String {
    essayTarget == 1 ? "Aufsatz" : "Aufsätze"
  }

  private func stepper(_ goal: WeeklyGoal, value: Binding<Int>, unit: String) -> some View {
    Stepper(value: value, in: goal.range) {
      Label {
        VStack(alignment: .leading, spacing: 2) {
          Text(goal.title)
          Text("\(value.wrappedValue) \(unit)")
            .font(.subheadline.monospacedDigit())
            .foregroundStyle(.secondary)
        }
      } icon: {
        Image(systemName: goal.systemImage)
          .font(.footnote.weight(.semibold))
          .foregroundStyle(goal.color)
          .frame(width: 28, height: 28)
          .background(.black, in: .rect(cornerRadius: 7))
      }
    }
  }
}
