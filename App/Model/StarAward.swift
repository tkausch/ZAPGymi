import Foundation
import SwiftData

/// Stars earned for one achievement. The key makes sure every achievement pays out only once.
@Model
final class StarAward {
  @Attribute(.unique) var key: String
  var kindRaw: String
  var stars: Int
  var title: String
  var date: Date

  init(key: String, kind: RewardKind, stars: Int, title: String, date: Date = .now) {
    self.key = key
    self.kindRaw = kind.rawValue
    self.stars = stars
    self.title = title
    self.date = date
  }

  var kind: RewardKind {
    RewardKind(rawValue: kindRaw) ?? .mistakeRepeated
  }
}
