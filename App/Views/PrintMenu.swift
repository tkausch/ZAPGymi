import SwiftUI
import UIKit

/// Toolbar menu to print the original exam documents of a task.
struct PrintMenu: View {
  var task: ExamTask
  /// Solutions are only offered once the child has revealed them.
  var includesSolution: Bool

  private var documents: [(kind: ExamDocumentKind, url: URL)] {
    var kinds: [ExamDocumentKind] = [.aufgaben]
    switch task.subject {
    case .sprache:
      kinds.append(.textblatt)
      if includesSolution { kinds.append(.loesungen) }
    case .mathematik:
      if includesSolution { kinds.append(.loesungen) }
    case .aufsatz:
      kinds.append(.korrektur)
    }
    return kinds.compactMap { kind in
      PDFLibrary.url(year: task.year, track: task.track, subject: task.subject, kind: kind).map { (kind, $0) }
    }
  }

  var body: some View {
    let documents = documents
    if !documents.isEmpty && UIPrintInteractionController.isPrintingAvailable {
      Menu("Drucken", systemImage: "printer") {
        ForEach(documents, id: \.kind) { document in
          Button(title(for: document.kind), systemImage: symbol(for: document.kind)) {
            print(document.url, kind: document.kind)
          }
        }
      }
    }
  }

  private func title(for kind: ExamDocumentKind) -> String {
    switch kind {
    case .aufgaben: task.subject == .aufsatz ? "Themenblatt" : "Prüfungsheft"
    case .textblatt: "Textblatt"
    case .loesungen: "Lösungen"
    case .korrektur: "Korrekturhinweise"
    }
  }

  private func symbol(for kind: ExamDocumentKind) -> String {
    switch kind {
    case .aufgaben: "doc.text"
    case .textblatt: "doc.plaintext"
    case .loesungen: "checkmark.seal"
    case .korrektur: "checklist"
    }
  }

  private func print(_ url: URL, kind: ExamDocumentKind) {
    let info = UIPrintInfo(dictionary: nil)
    info.outputType = .general
    info.jobName = "\(task.subject.title) \(task.year) \(task.track.shortTitle) – \(title(for: kind))"
    let controller = UIPrintInteractionController.shared
    controller.printInfo = info
    controller.printingItem = url
    controller.present(animated: true)
  }
}
