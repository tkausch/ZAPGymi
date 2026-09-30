import Foundation
import SwiftData

/// An essay the child writes in the app or on paper, with its self-assessment.
@Model
final class EssayDraft {
  var taskID: String
  var text: String
  var writesOnPaper: Bool
  var startedAt: Date
  var updatedAt: Date
  var finishedAt: Date?
  var checkedItems: [Int]
  var assessedAt: Date?

  init(taskID: String, writesOnPaper: Bool) {
    self.taskID = taskID
    self.text = ""
    self.writesOnPaper = writesOnPaper
    self.startedAt = .now
    self.updatedAt = .now
    self.finishedAt = nil
    self.checkedItems = []
    self.assessedAt = nil
  }

  var wordCount: Int {
    text.split { $0.isWhitespace || $0.isNewline }.count
  }
}
