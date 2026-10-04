import Foundation

/// What the child earns stars for.
enum RewardKind: String, CaseIterable, Identifiable {
  case ringClosed
  case allRings
  case examSimulation
  case mistakeRepeated
  case mistakeFixed

  var id: String { rawValue }

  var stars: Int {
    switch self {
    case .ringClosed: 10
    case .allRings: 20
    case .examSimulation: 15
    case .mistakeRepeated: 2
    case .mistakeFixed: 3
    }
  }

  var title: String {
    switch self {
    case .ringClosed: "Wochenring geschlossen"
    case .allRings: "Bonus: alle Ringe in einer Woche"
    case .examSimulation: "Probeprüfung ausgewertet"
    case .mistakeRepeated: "Früheren Fehler verbessert"
    case .mistakeFixed: "Extra, wenn er jetzt richtig ist"
    }
  }

  var systemImage: String {
    switch self {
    case .ringClosed: "circle.circle"
    case .allRings: "rosette"
    case .examSimulation: "timer"
    case .mistakeRepeated: "arrow.counterclockwise"
    case .mistakeFixed: "checkmark.circle"
    }
  }

  /// Big moments get a full-screen celebration, small ones a short banner.
  var isBigMoment: Bool {
    switch self {
    case .ringClosed, .allRings, .examSimulation: true
    case .mistakeRepeated, .mistakeFixed: false
    }
  }
}
