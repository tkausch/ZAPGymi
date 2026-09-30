import SwiftData
import SwiftUI

struct SimulationResultView: View {
  var session: ExamSession
  @Environment(\.catalog) private var catalog
  @Query private var attempts: [Attempt]
  @Query(sort: \ExamSession.startDate, order: .reverse) private var sessions: [ExamSession]

  var body: some View {
    let tasks = catalog.tasks(for: session.track, subject: session.subject, year: session.year)
    let sessionAttempts = attempts.filter { $0.sessionID == session.id }
    let total = score(of: sessionAttempts)
    let summary = ProgressSummary(attempts: sessionAttempts)

    List {
      Section {
        VStack(alignment: .leading, spacing: 6) {
          if let total {
            Text("\(total.points) von \(total.max) Punkten")
              .font(.largeTitle.bold())
              .monospacedDigit()
          } else {
            Text("\(sessionAttempts.filter { $0.outcome == .richtig }.count) von \(tasks.count) Aufgaben richtig")
              .font(.title.bold())
          }
          Text("Zeit: \(TimeFormatting.minutes(session.usedSeconds)) von \(TimeFormatting.minutes(session.durationSeconds))")
            .foregroundStyle(.secondary)
          if let comparison = comparisonText(current: total) {
            Text(comparison)
              .font(.subheadline)
          }
        }
        .accessibilityElement(children: .combine)
      } footer: {
        Text("Die Bestehensgrenze ist nicht bekannt. Die App sagt deshalb nichts über Bestehen oder Nichtbestehen.")
      }

      Section("Nach Thema") {
        ForEach(summary.topicStats(for: tasks, subject: session.subject)) { stat in
          LabeledContent(stat.topic) {
            Text(stat.score, format: .percent.precision(.fractionLength(0)))
              .monospacedDigit()
          }
        }
      }

      Section("Aufgaben") {
        ForEach(tasks) { task in
          LabeledContent {
            if let attempt = summary.latestByTask[task.id] {
              if let points = attempt.points, let max = attempt.maxPoints {
                Text("\(points) / \(max)")
                  .monospacedDigit()
              } else {
                Text(attempt.outcome.title)
              }
            }
          } label: {
            HStack {
              StatusIcon(status: summary.status(of: task))
              Text(task.displayTitle)
            }
          }
        }
      }
    }
    .navigationTitle("\(session.subject.title) \(String(session.year))")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func score(of attempts: [Attempt]) -> (points: Int, max: Int)? {
    let max = attempts.compactMap(\.maxPoints).reduce(0, +)
    guard max > 0 else { return nil }
    return (attempts.compactMap(\.points).reduce(0, +), max)
  }

  /// Compares with the previous graded simulation of the same subject.
  private func comparisonText(current: (points: Int, max: Int)?) -> String? {
    guard let current,
          let previous = sessions.first(where: {
            $0.id != session.id && $0.track == session.track && $0.subject == session.subject
              && $0.state == .graded && $0.startDate < session.startDate
          }),
          let before = score(of: attempts.filter { $0.sessionID == previous.id }) else { return nil }
    let now = Double(current.points) / Double(current.max)
    let then = Double(before.points) / Double(before.max)
    let difference = Int(((now - then) * 100).rounded())
    let previousLabel = "\(previous.subject.title) \(String(previous.year))"
    if difference > 0 { return "\(difference) Prozentpunkte besser als bei \(previousLabel)" }
    if difference < 0 { return "\(-difference) Prozentpunkte weniger als bei \(previousLabel)" }
    return "Gleich wie bei \(previousLabel)"
  }
}
