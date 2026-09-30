import Foundation

enum Subject: String, CaseIterable, Identifiable, Codable {
  case mathematik
  case sprache
  case aufsatz

  var id: String { rawValue }

  var title: String {
    switch self {
    case .mathematik: "Mathematik"
    case .sprache: "Sprachprüfung"
    case .aufsatz: "Aufsatz"
    }
  }

  var systemImage: String {
    switch self {
    case .mathematik: "function"
    case .sprache: "text.book.closed"
    case .aufsatz: "pencil.line"
    }
  }

  /// Subjects that are solved task by task and can be simulated with a timer.
  static let gradable: [Subject] = [.mathematik, .sprache]
}
