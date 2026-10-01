import SwiftData
import SwiftUI

/// The tasks the child marked as especially helpful, most recently marked first.
struct SavedTasksView: View {
  var track: ExamTrack
  @Environment(\.catalog) private var catalog
  @Environment(\.modelContext) private var modelContext
  @Query private var attempts: [Attempt]
  @Query(sort: \SavedTask.savedAt, order: .reverse) private var saved: [SavedTask]

  var body: some View {
    let summary = ProgressSummary(attempts: attempts)
    let tasks = Self.savedTasks(saved, catalog: catalog, track: track)

    List {
      if !tasks.isEmpty {
        Section {
          ForEach(tasks) { task in
            NavigationLink(value: task) {
              TaskRow(task: task, status: summary.status(of: task), isSaved: true)
            }
            .saveSwipeAction(for: task, isSaved: true, in: modelContext)
          }
        } footer: {
          Text("Gemerkte Aufgaben bleiben hier, bis du sie nicht mehr merkst. Wische nach rechts, um eine Aufgabe zu entfernen.")
        }
      }
    }
    .overlay {
      if tasks.isEmpty {
        ContentUnavailableView {
          Label("Noch nichts gemerkt", systemImage: "bookmark")
        } description: {
          Text("Tippe in einer Aufgabe auf das Lesezeichen, um sie dir zu merken. So findest du Aufgaben, die dir besonders geholfen haben, schnell wieder.")
        }
      }
    }
    .themedBackground()
    .navigationTitle("Gemerkte Aufgaben")
  }

  /// Marked tasks of the current exam type, most recently marked first.
  static func savedTasks(_ saved: [SavedTask], catalog: Catalog, track: ExamTrack) -> [ExamTask] {
    var seen = Set<String>()
    return saved.compactMap { entry in
      guard seen.insert(entry.taskID).inserted, let task = catalog.task(id: entry.taskID), task.track == track else { return nil }
      return task
    }
  }
}
