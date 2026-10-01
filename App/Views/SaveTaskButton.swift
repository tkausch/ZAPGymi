import SwiftData
import SwiftUI

/// Toolbar button to mark or unmark a task.
struct SaveTaskButton: View {
  var task: ExamTask
  @Environment(\.modelContext) private var modelContext
  @Query private var saved: [SavedTask]

  init(task: ExamTask) {
    self.task = task
    let id = task.id
    _saved = Query(filter: #Predicate<SavedTask> { $0.taskID == id })
  }

  private var isSaved: Bool { !saved.isEmpty }

  var body: some View {
    Button(isSaved ? "Nicht mehr merken" : "Aufgabe merken", systemImage: isSaved ? "bookmark.fill" : "bookmark") {
      SavedTask.toggle(taskID: task.id, in: modelContext)
    }
    .accessibilityValue(isSaved ? "Gemerkt" : "")
    .sensoryFeedback(.selection, trigger: isSaved)
  }
}

extension View {
  /// Adds a leading swipe action to mark or unmark the task of a list row.
  func saveSwipeAction(for task: ExamTask, isSaved: Bool, in context: ModelContext) -> some View {
    swipeActions(edge: .leading) {
      Button(isSaved ? "Nicht mehr merken" : "Merken", systemImage: isSaved ? "bookmark.slash" : "bookmark") {
        SavedTask.toggle(taskID: task.id, in: context)
      }
      .tint(.indigo)
    }
  }
}
