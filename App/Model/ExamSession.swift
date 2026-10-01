import Foundation
import SwiftData

/// A timed simulation of one subject of a past exam.
@Model
final class ExamSession {
  var id: UUID
  var year: Int
  var trackRaw: String
  var subjectRaw: String
  var startDate: Date
  var durationSeconds: Double
  var finishedAt: Date?
  var cancelledAt: Date?
  var gradedAt: Date?

  init(year: Int, track: ExamTrack, subject: Subject, durationSeconds: Double) {
    self.id = UUID()
    self.year = year
    self.trackRaw = track.rawValue
    self.subjectRaw = subject.rawValue
    self.startDate = .now
    self.durationSeconds = durationSeconds
  }

  var track: ExamTrack { ExamTrack(rawValue: trackRaw) ?? .langzeit }
  var subject: Subject { Subject(rawValue: subjectRaw) ?? .mathematik }
  var endDate: Date { startDate.addingTimeInterval(durationSeconds) }

  var state: State {
    if cancelledAt != nil { return .cancelled }
    if gradedAt != nil { return .graded }
    if finishedAt != nil { return .awaitingGrading }
    return .running
  }

  /// Time the child actually used, capped at the exam time.
  var usedSeconds: Double {
    let end = finishedAt ?? .now
    return min(end.timeIntervalSince(startDate), durationSeconds)
  }

  enum State {
    case running
    case awaitingGrading
    case graded
    case cancelled
  }
}

extension ExamSession {
  /// Result of a graded simulation from 0 to 1: share of points, or share of correct answers
  /// for exams without points.
  func result(from attempts: [Attempt]) -> Double? {
    let sessionAttempts = attempts.filter { $0.sessionID == id }
    guard !sessionAttempts.isEmpty else { return nil }
    let maxPoints = sessionAttempts.compactMap(\.maxPoints).reduce(0, +)
    if maxPoints > 0 {
      return Double(sessionAttempts.compactMap(\.points).reduce(0, +)) / Double(maxPoints)
    }
    return sessionAttempts.map(\.outcome.score).reduce(0, +) / Double(sessionAttempts.count)
  }
}
