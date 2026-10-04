import Foundation

/// The mascot grows with all stars ever earned. Spending stars never makes it smaller.
enum MascotStage: Int, CaseIterable, Comparable {
  case ei
  case kueken
  case jungvogel
  case ueberflieger

  static let mascotName = "Pico"

  var title: String {
    switch self {
    case .ei: "Ei"
    case .kueken: "Küken"
    case .jungvogel: "Jungvogel"
    case .ueberflieger: "Überflieger"
    }
  }

  var minimumStars: Int {
    switch self {
    case .ei: 0
    case .kueken: 30
    case .jungvogel: 150
    case .ueberflieger: 400
    }
  }

  var systemImage: String {
    self == .ei ? "oval.portrait.fill" : "bird.fill"
  }

  /// Size of the mascot relative to its frame.
  var scale: Double {
    switch self {
    case .ei: 0.5
    case .kueken: 0.62
    case .jungvogel: 0.78
    case .ueberflieger: 0.92
    }
  }

  var next: MascotStage? {
    MascotStage(rawValue: rawValue + 1)
  }

  static func stage(forEarned stars: Int) -> MascotStage {
    allCases.last { stars >= $0.minimumStars } ?? .ei
  }

  static func < (lhs: MascotStage, rhs: MascotStage) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}
