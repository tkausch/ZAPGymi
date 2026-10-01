import SwiftData
import SwiftUI

/// The detailed rate per topic for math and language, weakest first.
struct TopicDetailsView: View {
  var track: ExamTrack
  @Environment(\.catalog) private var catalog
  @Query private var attempts: [Attempt]

  var body: some View {
    let tasks = catalog.tasks(for: track)
    let summary = ProgressSummary(attempts: attempts)

    List {
      ForEach(Subject.gradable) { subject in
        let stats = summary.topicStats(for: tasks, subject: subject).filter { $0.attempted > 0 }
        Section {
          if stats.isEmpty {
            Text("Noch keine Aufgabe eingeschätzt.")
              .foregroundStyle(.secondary)
          }
          ForEach(stats) { stat in
            TopicStatRow(stat: stat)
          }
        } header: {
          Text(subject.title)
        } footer: {
          Text("Schwächste Themen zuerst. Eine Quote erscheint ab \(TopicStat.minimumAttempts) eingeschätzten Aufgaben.")
        }
      }
    }
    .themedBackground()
    .navigationTitle("Alle Themen")
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
      } else {
        Text("Noch zu wenig Daten (\(stat.attempted) von \(TopicStat.minimumAttempts))")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .accessibilityElement(children: .combine)
  }
}
