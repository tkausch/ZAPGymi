import Foundation
import SwiftData

/// A task the child marked as especially helpful. It stays in the review list until it is unmarked.
@Model
final class SavedTask {
  var taskID: String
  var savedAt: Date

  init(taskID: String, savedAt: Date = .now) {
    self.taskID = taskID
    self.savedAt = savedAt
  }

  /// Marks the task, or removes the mark if it is already set.
  static func toggle(taskID: String, in context: ModelContext) {
    let descriptor = FetchDescriptor<SavedTask>(predicate: #Predicate { $0.taskID == taskID })
    let existing = (try? context.fetch(descriptor)) ?? []
    if existing.isEmpty {
      context.insert(SavedTask(taskID: taskID))
    } else {
      existing.forEach(context.delete)
    }
  }
}
