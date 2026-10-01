import Foundation

enum TaskStatus {
  case open
  case done(Outcome)

  var outcome: Outcome? {
    if case .done(let outcome) = self { outcome } else { nil }
  }
}

struct TopicStat: Identifiable {
  var subject: Subject
  var topic: String
  var attempted: Int
  var total: Int
  /// Estimated share of points, smoothed with (correct + 1) / (attempted + 2),
  /// so that wrong answers count and a single result does not show 0 % or 100 %.
  var score: Double
  /// Plain share of points actually reached, e.g. for the result of one simulation.
  var reachedShare: Double

  var id: String { "\(subject.rawValue)-\(topic)" }

  /// Assumption: below five graded tasks a percentage would be misleading.
  static let minimumAttempts = 5

  var hasEnoughData: Bool { attempted >= Self.minimumAttempts }
}

/// Derives progress, reviews and suggestions from the child's attempts.
struct ProgressSummary {
  /// Assumption: a practice set has ten tasks.
  static let practiceSetSize = 10

  private(set) var latestByTask: [String: Attempt] = [:]
  private let attempts: [Attempt]

  init(attempts: [Attempt]) {
    self.attempts = attempts
    for attempt in attempts {
      if let existing = latestByTask[attempt.taskID], existing.date >= attempt.date { continue }
      latestByTask[attempt.taskID] = attempt
    }
  }

  func status(of task: ExamTask) -> TaskStatus {
    latestByTask[task.id].map { .done($0.outcome) } ?? .open
  }

  func attempts(for task: ExamTask) -> [Attempt] {
    attempts.filter { $0.taskID == task.id }.sorted { $0.date > $1.date }
  }

  /// Tasks whose latest attempt was not fully correct, right after grading.
  func dueReviews(in tasks: [ExamTask]) -> [ExamTask] {
    tasks.filter { task in
      guard let latest = latestByTask[task.id], task.subject != .aufsatz else { return false }
      return latest.outcome != .richtig
    }
    .sorted { (latestByTask[$0.id]?.date ?? .distantPast) < (latestByTask[$1.id]?.date ?? .distantPast) }
  }

  func topicStats(for tasks: [ExamTask], subject: Subject) -> [TopicStat] {
    let grouped = Dictionary(grouping: tasks.filter { $0.subject == subject }, by: \.topic)
    return grouped.map { topic, topicTasks in
      let graded = topicTasks.compactMap { latestByTask[$0.id] }
      // A fully correct task counts 1, partial points count proportionally, a wrong task 0.
      let correct = graded.map(\.score).reduce(0, +)
      let attempted = Double(graded.count)
      return TopicStat(
        subject: subject,
        topic: topic,
        attempted: graded.count,
        total: topicTasks.count,
        score: (correct + 1) / (attempted + 2),
        reachedShare: graded.isEmpty ? 0 : correct / attempted
      )
    }
    .sorted { lhs, rhs in
      if lhs.hasEnoughData != rhs.hasEnoughData { return lhs.hasEnoughData }
      if lhs.hasEnoughData { return lhs.score < rhs.score }
      return lhs.topic < rhs.topic
    }
  }

  /// The weakest topics with enough data, weakest first.
  func weakTopics(for tasks: [ExamTask]) -> [TopicStat] {
    Subject.gradable
      .flatMap { topicStats(for: tasks, subject: $0) }
      .filter { $0.hasEnoughData && $0.score < 0.8 }
      .sorted { $0.score < $1.score }
  }

  /// Up to ten tasks from the three weakest topics, unsolved tasks first.
  func weaknessPracticeSet(from tasks: [ExamTask]) -> [ExamTask] {
    let topics = weakTopics(for: tasks).prefix(3)
    let candidates = tasks.filter { task in
      task.isAvailable && topics.contains { $0.subject == task.subject && $0.topic == task.topic }
    }
    let open = candidates.filter { latestByTask[$0.id] == nil }
    let retry = candidates.filter { latestByTask[$0.id].map { $0.outcome != .richtig } ?? false }
    return Array((open + retry).prefix(Self.practiceSetSize))
  }

  /// The next task to practise: easy math first for beginners, later the least practised topic.
  func suggestion(from tasks: [ExamTask]) -> ExamTask? {
    let open = tasks.filter { Subject.gradable.contains($0.subject) && latestByTask[$0.id] == nil && $0.isAvailable }
    if latestByTask.isEmpty {
      return open
        .filter { $0.subject == .mathematik && $0.difficulty == .leicht }
        .max { $0.year < $1.year }
        ?? open.first
    }
    if let weakest = weakTopics(for: tasks).first,
       let task = open.first(where: { $0.subject == weakest.subject && $0.topic == weakest.topic }) {
      return task
    }
    let practiceCount = Dictionary(grouping: latestByTask.keys.compactMap { id in tasks.first { $0.id == id } }, by: \.topic)
      .mapValues(\.count)
    return open.min { lhs, rhs in
      let lhsCount = practiceCount[lhs.topic] ?? 0
      let rhsCount = practiceCount[rhs.topic] ?? 0
      if lhsCount != rhsCount { return lhsCount < rhsCount }
      return (lhs.difficulty ?? .mittel) < (rhs.difficulty ?? .mittel)
    }
  }

  /// Number of distinct days with at least one attempt in the current week.
  func practiceDaysThisWeek(calendar: Calendar = .current, now: Date = .now) -> Int {
    guard let week = calendar.dateInterval(of: .weekOfYear, for: now) else { return 0 }
    let days = attempts
      .filter { week.contains($0.date) }
      .map { calendar.startOfDay(for: $0.date) }
    return Set(days).count
  }
}
