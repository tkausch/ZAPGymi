import PDFKit
import SwiftUI

/// Shows a PDF from its first page.
struct PDFKitView: UIViewRepresentable {
  var document: PDFDocument

  func makeUIView(context: Context) -> PDFView {
    let view = PDFView()
    view.autoScales = true
    view.displayMode = .singlePageContinuous
    view.displayDirection = .vertical
    view.backgroundColor = .secondarySystemBackground
    view.document = document
    // SwiftUI already lays the view out inside the safe area; extra insets would hide the top of the page.
    for case let scrollView as UIScrollView in view.subviews {
      scrollView.contentInsetAdjustmentBehavior = .never
    }
    return view
  }

  func updateUIView(_ view: PDFView, context: Context) {
    if view.document !== document {
      view.document = document
    }
  }
}

/// A PDF of a task, or an explanation when it is missing.
struct ExamDocumentView: View {
  var task: ExamTask
  var kind: ExamDocumentKind
  @State private var loaded: PDFDocument?
  @State private var isMissing = false

  var body: some View {
    Group {
      if let loaded {
        PDFKitView(document: loaded)
      } else if isMissing {
        ContentUnavailableView {
          Label("Kein \(kind.title) vorhanden", systemImage: "doc.questionmark")
        } description: {
          Text(missingDescription)
        }
      } else {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .task(id: "\(task.id)-\(kind.rawValue)") {
      loaded = nil
      isMissing = false
      if let document = PDFLibrary.document(for: task, kind: kind) {
        let page = PDFLibrary.pageIndex(for: task, in: document, kind: kind)
        loaded = Self.pages(of: document, from: page)
      } else {
        isMissing = true
      }
    }
  }

  /// The document starting at the task's page, so it opens right at the task.
  private static func pages(of document: PDFDocument, from start: Int) -> PDFDocument {
    guard start > 0 else { return document }
    let subset = PDFDocument()
    for index in start..<document.pageCount {
      if let page = document.page(at: index)?.copy() as? PDFPage {
        subset.insert(page, at: subset.pageCount)
      }
    }
    return subset.pageCount > 0 ? subset : document
  }

  private var missingDescription: String {
    switch kind {
    case .loesungen: "Für diesen Jahrgang liegt keine offizielle Lösung vor. Du kannst dich trotzdem selbst einschätzen."
    case .textblatt: "Für diesen Jahrgang fehlt das Textblatt mit dem Lesetext."
    case .aufgaben: "Das Prüfungsheft dieses Jahrgangs ist noch nicht in der App."
    case .korrektur: "Für dieses Thema gibt es keine offiziellen Korrekturhinweise."
    }
  }
}

/// A full-screen sheet that shows one document of a task.
struct DocumentSheet: View {
  var task: ExamTask
  var kind: ExamDocumentKind
  var title: String
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ExamDocumentView(task: task, kind: kind)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Fertig") { dismiss() }
          }
        }
    }
  }
}
