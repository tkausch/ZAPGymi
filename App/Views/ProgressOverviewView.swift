import SwiftData
import SwiftUI

struct ProgressOverviewView: View {
  var track: ExamTrack
  @Binding var selectedTab: AppTab
  @Environment(\.catalog) private var catalog
  @Query private var attempts: [Attempt]

  var body: some View {
    let tasks = catalog.tasks(for: track)
    let taskIDs = Set(tasks.map(\.id))
    let trackAttempts = attempts.filter { taskIDs.contains($0.taskID) }
    let summary = ProgressSummary(attempts: trackAttempts)

    NavigationStack {
      Group {
        if trackAttempts.isEmpty {
          ContentUnavailableView {
            Label("Noch kein Fortschritt", systemImage: "chart.bar")
          } description: {
            Text("Nach jeder Aufgabe schätzt du dich selbst ein. Daraus entsteht hier dein Stand pro Thema.")
          } actions: {
            Button("Erste Aufgabe lösen") { selectedTab = .today }
              .buttonStyle(.borderedProminent)
          }
        } else {
          List {
            Section("Überblick") {
              LabeledContent("Bearbeitete Aufgaben", value: "\(summary.latestByTask.count) von \(tasks.count)")
              LabeledContent("Übungstage diese Woche", value: "\(summary.practiceDaysThisWeek())")
              NavigationLink {
                TaskListScreen(
                  title: "Schwächen üben",
                  tasks: summary.weaknessPracticeSet(from: tasks),
                  emptyTitle: "Noch keine Schwächen erkannt",
                  emptyDescription: "Löse zuerst mindestens \(TopicStat.minimumAttempts) Aufgaben in einem Thema.",
                  footnote: nil
                )
              } label: {
                Label("Schwächen üben", systemImage: "target")
              }
            }

            ForEach(Subject.gradable) { subject in
              Section {
                ForEach(summary.topicStats(for: tasks, subject: subject).filter { $0.attempted > 0 }) { stat in
                  TopicStatRow(stat: stat)
                }
              } header: {
                Text(subject.title)
              } footer: {
                Text("Schwächste Themen zuerst. Eine Quote erscheint ab \(TopicStat.minimumAttempts) eingeschätzten Aufgaben.")
              }
            }

            let essays = trackAttempts.filter { attempt in tasks.first { $0.id == attempt.taskID }?.subject == .aufsatz }
            Section("Aufsatz") {
              LabeledContent("Eingeschätzte Aufsätze", value: "\(essays.count)")
            }
          }
        }
      }
      .navigationTitle("Fortschritt")
      .examTaskDestinations()
    }
  }
}

private struct TopicStatRow: View {
  var stat: TopicStat

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(stat.topic)
        Spacer()
        if stat.hasEnoughData {
          Text(stat.score, format: .percent.precision(.fractionLength(0)))
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
      }
      if stat.hasEnoughData {
        ProgressView(value: stat.score)
          .tint(stat.score < 0.5 ? .orange : .accentColor)
      } else {
        Text("Noch zu wenig Daten (\(stat.attempted) von \(TopicStat.minimumAttempts))")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .accessibilityElement(children: .combine)
  }
}
