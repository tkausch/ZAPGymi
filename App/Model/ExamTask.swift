import Foundation

/// One task of a past exam: a math or language task, or an essay topic.
struct ExamTask: Identifiable, Hashable {
  var id: String
  var year: Int
  var number: String
  var track: ExamTrack
  var subject: Subject
  var title: String?
  var text: String
  var topic: String
  var topicDetail: String?
  var difficulty: Difficulty?
  var maxPoints: Int?

  var displayTitle: String {
    switch subject {
    case .aufsatz:
      if let title, !title.isEmpty, !title.contains("kein Titel") {
        return title
      }
      return "Thema \(number) (eigener Titel)"
    case .mathematik, .sprache:
      return "Aufgabe \(number)"
    }
  }

  /// True when the essay topic asks the child to choose a title.
  var needsOwnTitle: Bool {
    subject == .aufsatz && (title?.contains("kein Titel") ?? true)
  }

  /// The leading number, e.g. "1" for "1a".
  var baseNumber: String {
    String(number.prefix { $0.isNumber })
  }

  var sortKey: (Int, String) {
    (Int(baseNumber) ?? 0, number)
  }

  var isAvailable: Bool {
    switch subject {
    case .aufsatz:
      true
    case .mathematik, .sprache:
      PDFLibrary.url(year: year, track: track, subject: subject, kind: .aufgaben) != nil
    }
  }
}
