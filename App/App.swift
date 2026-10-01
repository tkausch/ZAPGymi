import SwiftData
import SwiftUI

@main
struct AppDefinition: App {
  private let catalog = Catalog.load()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(\.catalog, catalog)
    }
    .modelContainer(for: [Attempt.self, EssayDraft.self, ExamSession.self, SavedTask.self])
  }
}
