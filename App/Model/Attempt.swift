import Foundation
import SwiftData

/// How the child rated their own answer after comparing it with the solution.
enum Outcome: String, CaseIterable, Identifiable {
  case richtig
  case teilweise
  case falsch

  var id: String { rawValue }

  var title: String {
    switch self {
    case .richtig: "Richtig"
    case .teilweise: "Teilweise"
    case .falsch: "Falsch"
    }
  }

  var systemImage: String {
    switch self {
    case .richtig: "checkmark.circle.fill"
    case .teilweise: "circle.lefthalf.filled"
    case .falsch: "xmark.circle.fill"
    }
  }

  var score: Double {
    switch self {
    case .richtig: 1
    case .teilweise: 0.5
    case .falsch: 0
    }
  }

  init(points: Int, maxPoints: Int) {
    if points >= maxPoints {
      self = .richtig
    } else if points <= 0 {
      self = .falsch
    } else {
      self = .teilweise
    }
  }
}

/// One self-graded attempt at a task, in practice or in a simulation.
@Model
final class Attempt {
  var taskID: String
  var date: Date
  var points: Int?
  var maxPoints: Int?
  var outcomeRaw: String
  var sessionID: UUID?

  init(taskID: String, date: Date = .now, points: Int?, maxPoints: Int?, outcome: Outcome, sessionID: UUID? = nil) {
    self.taskID = taskID
    self.date = date
    self.points = points
    self.maxPoints = maxPoints
    self.outcomeRaw = outcome.rawValue
    self.sessionID = sessionID
  }

  var outcome: Outcome {
    Outcome(rawValue: outcomeRaw) ?? .falsch
  }

  /// Share of the possible result, from 0 to 1.
  var score: Double {
    if let points, let maxPoints, maxPoints > 0 {
      return Double(points) / Double(maxPoints)
    }
    return outcome.score
  }
}
