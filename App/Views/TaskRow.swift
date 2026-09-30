import SwiftUI

struct TaskRow: View {
  var task: ExamTask
  var status: TaskStatus
  var showsYear = true

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      StatusIcon(status: status)
      VStack(alignment: .leading, spacing: 4) {
        Text(showsYear ? "\(task.displayTitle) · \(String(task.year))" : task.displayTitle)
          .font(.headline)
        Text(task.text)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(2)
        TaskTags(task: task)
        if !task.isAvailable {
          Text("PDF noch nicht verfügbar")
            .font(.caption)
            .foregroundStyle(.orange)
        }
      }
    }
    .accessibilityElement(children: .combine)
  }
}

struct StatusIcon: View {
  var status: TaskStatus

  var body: some View {
    Group {
      if let outcome = status.outcome {
        Image(systemName: outcome.systemImage)
          .foregroundStyle(color(for: outcome))
          .accessibilityLabel(outcome.title)
      } else {
        Image(systemName: "circle")
          .foregroundStyle(.tertiary)
          .accessibilityLabel("Offen")
      }
    }
    .font(.title3)
  }

  private func color(for outcome: Outcome) -> Color {
    switch outcome {
    case .richtig: .green
    case .teilweise: .orange
    case .falsch: .red
    }
  }
}

struct TaskTags: View {
  var task: ExamTask

  var body: some View {
    HStack(spacing: 6) {
      if task.subject != .aufsatz {
        Text(task.topic)
      }
      if let difficulty = task.difficulty {
        Text("· \(difficulty.title)")
      }
      if let points = task.maxPoints {
        Text("· \(points) P.")
      }
    }
    .font(.caption)
    .foregroundStyle(.secondary)
  }
}
