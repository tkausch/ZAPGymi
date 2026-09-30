import SwiftUI

struct TipsView: View {
  var track: ExamTrack
  @Environment(\.catalog) private var catalog

  var body: some View {
    let mathTasks = catalog.tasks(for: track, subject: .mathematik)
    let statistics = TopicStatistics(tasks: mathTasks)
    let largestShare = statistics.topics.first?.pointShare ?? 1

    NavigationStack {
      List {
        Section(track.title) {
          ForEach(LearningTip.tips(for: track)) { tip in
            TipRow(tip: tip)
          }
        }

        Section("Für alle") {
          TipRow(tip: LearningTip.general)
        }

        Section {
          ForEach(statistics.topics) { topic in
            NavigationLink(value: TaskListRoute.mathTopic(track, topic.topic)) {
              TopicStatisticRow(statistic: topic, largestShare: largestShare, yearCount: statistics.years.count)
            }
          }
        } header: {
          Text("Mathe-Themen \(statistics.yearRange)")
        } footer: {
          Text("Ausgewertet: \(statistics.taskCount) Mathematikaufgaben mit zusammen \(statistics.totalPoints) Punkten aus \(statistics.years.count) Jahrgängen. Themen mit vielen Punkten lohnen sich beim Üben besonders.")
        }
      }
      .themedBackground()
      .navigationTitle("Tipps")
      .examTaskDestinations()
    }
  }
}

private struct TipRow: View {
  var tip: LearningTip

  var body: some View {
    Label {
      VStack(alignment: .leading, spacing: 4) {
        Text(tip.title)
          .font(.headline)
        Text(tip.text)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    } icon: {
      Image(systemName: tip.systemImage)
        .foregroundStyle(.tint)
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
  }
}

private struct TopicStatisticRow: View {
  var statistic: TopicStatistic
  var largestShare: Double
  var yearCount: Int

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(alignment: .firstTextBaseline) {
        Text(statistic.topic)
        Spacer()
        Group {
          if statistic.pointShare > 0 && statistic.pointShare < 0.005 {
            Text("< 1 %")
          } else {
            Text(statistic.pointShare, format: .percent.precision(.fractionLength(0)))
          }
        }
        .monospacedDigit()
        .foregroundStyle(.secondary)
      }
      ProgressView(value: statistic.pointShare, total: max(largestShare, 0.0001))
        .accessibilityHidden(true)
      Text(detailText)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .accessibilityElement(children: .combine)
  }

  private var detailText: String {
    let points = statistic.points == 1 ? "1 Punkt" : "\(statistic.points) Punkte"
    let tasks = statistic.taskCount == 1 ? "1 Aufgabe" : "\(statistic.taskCount) Aufgaben"
    return "\(points) · \(tasks) · in \(statistic.years.count) von \(yearCount) Jahren"
  }
}
