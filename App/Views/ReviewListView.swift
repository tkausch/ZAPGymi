import SwiftData
import SwiftUI

/// «Zu wiederholen»: marked tasks and tasks whose last attempt was not fully correct.
struct ReviewListView: View {
  var track: ExamTrack
  @Environment(\.catalog) private var catalog
  @Environment(\.modelContext) private var modelContext
  @Query private var attempts: [Attempt]
  @Query(sort: \SavedTask.savedAt, order: .reverse) private var saved: [SavedTask]

  var body: some View {
    let summary = ProgressSummary(attempts: attempts)
    let savedTasks = Self.savedTasks(saved, catalog: catalog, track: track)
    let savedIDs = Set(savedTasks.map(\.id))
    let wrongTasks = summary.dueReviews(in: catalog.tasks(for: track)).filter { !savedIDs.contains($0.id) }

    List {
      if !savedTasks.isEmpty {
        Section {
          ForEach(savedTasks) { task in
            row(task, summary: summary, isSaved: true)
          }
        } header: {
          Label("Gemerkt", systemImage: "bookmark.fill")
        } footer: {
          Text("Bleiben hier, bis du sie nicht mehr merkst. Wische nach rechts, um eine Aufgabe zu entfernen.")
        }
      }

      if !wrongTasks.isEmpty {
        Section {
          ForEach(wrongTasks) { task in
            row(task, summary: summary, isSaved: false)
          }
        } header: {
          Label("Noch nicht ganz richtig", systemImage: "arrow.counterclockwise")
        } footer: {
          Text("Stehen hier, bis du sie richtig löst.")
        }
      }
    }
    .overlay {
      if savedTasks.isEmpty && wrongTasks.isEmpty {
        ContentUnavailableView {
          Label("Nichts zu wiederholen", systemImage: "checkmark.seal")
        } description: {
          Text("Alle bearbeiteten Aufgaben stimmen. Mit dem Lesezeichen merkst du dir Aufgaben, die dir besonders geholfen haben.")
        }
      }
    }
    .themedBackground()
    .navigationTitle("Zu wiederholen")
  }

  private func row(_ task: ExamTask, summary: ProgressSummary, isSaved: Bool) -> some View {
    NavigationLink(value: task) {
      TaskRow(task: task, status: summary.status(of: task), isSaved: isSaved)
    }
    .saveSwipeAction(for: task, isSaved: isSaved, in: modelContext)
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
