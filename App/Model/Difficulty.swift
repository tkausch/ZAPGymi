import Foundation

enum Difficulty: Int, CaseIterable, Identifiable, Comparable {
  case leicht
  case mittel
  case mittelSchwer
  case schwer

  var id: Int { rawValue }

  /// The data uses both "leicht" and "einfach" for the easiest level.
  init?(dataValue: String) {
    switch dataValue.lowercased() {
    case "leicht", "einfach": self = .leicht
    case "mittel": self = .mittel
    case "mittel-schwer": self = .mittelSchwer
    case "schwer": self = .schwer
    default: return nil
    }
  }

  var title: String {
    switch self {
    case .leicht: "Leicht"
    case .mittel: "Mittel"
    case .mittelSchwer: "Mittelschwer"
    case .schwer: "Schwer"
    }
  }

  static func < (lhs: Difficulty, rhs: Difficulty) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}
