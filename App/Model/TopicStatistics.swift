import Foundation

/// How often a math topic appeared in past exams and how many points it was worth.
struct TopicStatistic: Identifiable {
  var topic: String
  var taskCount: Int
  var points: Int
  var years: Set<Int>
  var pointShare: Double

  var id: String { topic }
}

/// Topic statistics for all past exams of one subject, computed from the bundled task data.
struct TopicStatistics {
  var topics: [TopicStatistic]
  var taskCount: Int
  var totalPoints: Int
  var years: [Int]

  init(tasks: [ExamTask]) {
    let totalPoints = tasks.compactMap(\.maxPoints).reduce(0, +)
    self.totalPoints = totalPoints
    self.taskCount = tasks.count
    self.years = Set(tasks.map(\.year)).sorted()
    self.topics = Dictionary(grouping: tasks, by: \.topic)
      .map { topic, topicTasks in
        let points = topicTasks.compactMap(\.maxPoints).reduce(0, +)
        return TopicStatistic(
          topic: topic,
          taskCount: topicTasks.count,
          points: points,
          years: Set(topicTasks.map(\.year)),
          pointShare: totalPoints > 0 ? Double(points) / Double(totalPoints) : 0
        )
      }
      .sorted { lhs, rhs in
        lhs.points != rhs.points ? lhs.points > rhs.points : lhs.topic < rhs.topic
      }
  }

  var yearRange: String {
    guard let first = years.first, let last = years.last else { return "" }
    return first == last ? String(first) : "\(first)–\(last)"
  }
}
