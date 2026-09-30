import SwiftData
import SwiftUI

extension View {
  /// Opens math and language tasks in the task view and essay topics in the essay view.
  func examTaskDestinations() -> some View {
    navigationDestination(for: ExamTask.self) { task in
      if task.subject == .aufsatz {
        EssayDetailView(task: task)
      } else {
        TaskDetailView(task: task)
      }
    }
  }
}

/// A simple list of tasks, used for reviews and practice sets.
struct TaskListScreen: View {
  var title: String
  var tasks: [ExamTask]
  var emptyTitle: String
  var emptyDescription: String
  var footnote: String?
  @Query private var attempts: [Attempt]

  var body: some View {
    let summary = ProgressSummary(attempts: attempts)
    List {
      if let footnote {
        Section {
          Text(footnote)
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
      ForEach(tasks) { task in
        NavigationLink(value: task) {
          TaskRow(task: task, status: summary.status(of: task))
        }
      }
    }
    .overlay {
      if tasks.isEmpty {
        ContentUnavailableView(emptyTitle, systemImage: "checkmark.seal", description: Text(emptyDescription))
      }
    }
    .navigationTitle(title)
  }
}
