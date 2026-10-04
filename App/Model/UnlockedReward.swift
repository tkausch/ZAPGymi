import Foundation
import SwiftData

/// An extra the child unlocked with stars, such as a colour theme or mascot accessory.
@Model
final class UnlockedReward {
  @Attribute(.unique) var itemID: String
  var cost: Int
  var date: Date

  init(itemID: String, cost: Int, date: Date = .now) {
    self.itemID = itemID
    self.cost = cost
    self.date = date
  }
}
