import SwiftData
import SwiftUI

/// A list of tasks that can be pushed onto a navigation stack by value.
/// All links in a stack must be value-based, otherwise opening a task pops the list again.
enum TaskListRoute: Hashable {
  case reviews(ExamTrack)
  case saved(ExamTrack)
  case weaknesses(ExamTrack)
  case mathTopic(ExamTrack, String)
}

extension View {
  /// Opens tasks, essay topics and task lists that were pushed by value.
  func examTaskDestinations() -> some View {
    self
      .navigationDestination(for: ExamTask.self) { task in
        if task.subject == .aufsatz {
          EssayDetailView(task: task)
        } else {
          TaskDetailView(task: task)
        }
      }
      .navigationDestination(for: TaskListRoute.self) { route in
        TaskListRouteView(route: route)
      }
  }
}

/// Computes the tasks of a route from the current progress, so the list stays up to date.
struct TaskListRouteView: View {
  var route: TaskListRoute
  @Environment(\.catalog) private var catalog
  @Query private var attempts: [Attempt]

  var body: some View {
    let summary = ProgressSummary(attempts: attempts)
    switch route {
    case .reviews(let track):
      TaskListScreen(
        title: "Zu wiederholen",
        tasks: summary.dueReviews(in: catalog.tasks(for: track)),
        emptyTitle: "Nichts zu wiederholen",
        emptyDescription: "Alle bearbeiteten Aufgaben stimmen. Löse eine neue Aufgabe.",
        footnote: "Aufgaben, die nicht ganz gestimmt haben, stehen hier, bis du sie richtig löst."
      )
    case .saved(let track):
      SavedTasksView(track: track)
    case .weaknesses(let track):
      let practiceSet = summary.weaknessPracticeSet(from: catalog.tasks(for: track))
      TaskListScreen(
        title: "Schwächen üben",
        tasks: practiceSet,
        emptyTitle: "Noch keine Schwächen erkannt",
        emptyDescription: "Löse zuerst mindestens \(TopicStat.minimumAttempts) Aufgaben in einem Thema. Dann stellt die App hier Aufgaben aus deinen schwächsten Themen zusammen.",
        footnote: practiceSet.isEmpty ? nil : "Aufgaben aus deinen schwächsten Themen, ungelöste zuerst."
      )
    case .mathTopic(let track, let topic):
      TaskListScreen(
        title: topic,
        tasks: catalog.tasks(for: track, subject: .mathematik)
          .filter { $0.topic == topic }
          .sorted { $0.year != $1.year ? $0.year > $1.year : $0.sortKey < $1.sortKey },
        emptyTitle: "Keine Aufgaben",
        emptyDescription: "Zu diesem Thema gibt es keine Aufgaben.",
        footnote: nil
      )
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
  @Environment(\.modelContext) private var modelContext
  @Query private var attempts: [Attempt]
  @Query private var saved: [SavedTask]

  var body: some View {
    let summary = ProgressSummary(attempts: attempts)
    let savedIDs = Set(saved.map(\.taskID))
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
          TaskRow(task: task, status: summary.status(of: task), isSaved: savedIDs.contains(task.id))
        }
        .saveSwipeAction(for: task, isSaved: savedIDs.contains(task.id), in: modelContext)
      }
    }
    .overlay {
      if tasks.isEmpty {
        ContentUnavailableView(emptyTitle, systemImage: "checkmark.seal", description: Text(emptyDescription))
      }
    }
    .themedBackground()
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(title.count > 18 ? .inline : .automatic)
  }
}
