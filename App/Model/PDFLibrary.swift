import Foundation
import PDFKit

/// The kind of document bundled for a year, track and subject.
enum ExamDocumentKind: String, CaseIterable, Identifiable {
  case aufgaben
  case textblatt
  case loesungen
  case korrektur

  var id: String { rawValue }

  var title: String {
    switch self {
    case .aufgaben: "Aufgabe"
    case .textblatt: "Textblatt"
    case .loesungen: "Lösung"
    case .korrektur: "Korrekturhinweise"
    }
  }
}

/// Finds the bundled exam PDFs, named "<year>-<lg|kg>-<subject>-<kind>.pdf".
enum PDFLibrary {
  static func url(year: Int, track: ExamTrack, subject: Subject, kind: ExamDocumentKind) -> URL? {
    let name = "\(year)-\(track.fileCode)-\(subject.rawValue)-\(kind.rawValue)"
    return Bundle.main.url(forResource: name, withExtension: "pdf")
      ?? Bundle.main.url(forResource: name, withExtension: "pdf", subdirectory: "PDF")
  }

  static func document(for task: ExamTask, kind: ExamDocumentKind) -> PDFDocument? {
    url(year: task.year, track: task.track, subject: task.subject, kind: kind)
      .flatMap(PDFDocument.init(url:))
  }

  /// Best guess for the page that shows the task. Scanned PDFs have no text, so they open on the first page.
  static func pageIndex(for task: ExamTask, in document: PDFDocument, kind: ExamDocumentKind) -> Int {
    let number = NSRegularExpression.escapedPattern(for: task.baseNumber)
    var patterns: [String]
    switch task.subject {
    case .aufsatz:
      let title = NSRegularExpression.escapedPattern(for: task.title ?? "")
      patterns = task.needsOwnTitle ? [#"(?m)^\s*Thema\s+"# + number + #"\b"#] : [title, #"(?m)^\s*Thema\s+"# + number + #"\b"#]
    case .mathematik, .sprache:
      let taskHeading = #"(?m)^\s*Aufgabe\s+"# + number + #"\b"#
      let numbered = #"(?m)^\s*"# + number + #"\.(?!\d)"#
      let lettered = #"(?m)^\s*"# + number + #"\s*[a-z]\)"#
      patterns = task.subject == .mathematik && kind == .aufgaben
        ? [numbered, taskHeading, lettered]
        : [taskHeading, numbered, lettered]
    }
    // Skip the cover page first: it often lists all task numbers in a table.
    let order = Array(1..<max(document.pageCount, 1)) + [0]
    for pattern in patterns where !pattern.isEmpty {
      guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
      for index in order where index < document.pageCount {
        guard let text = document.page(at: index)?.string else { continue }
        if regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
          return index
        }
      }
    }
    return 0
  }
}
