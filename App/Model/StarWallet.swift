import SwiftUI

/// The child's stars: everything earned, what was spent on extras, and what is left.
struct StarWallet {
  var earned: Int
  var spent: Int
  var unlockedIDs: Set<String>

  init(awards: [StarAward], unlocks: [UnlockedReward]) {
    earned = awards.map(\.stars).reduce(0, +)
    spent = unlocks.map(\.cost).reduce(0, +)
    unlockedIDs = Set(unlocks.map(\.itemID))
  }

  var balance: Int { max(earned - spent, 0) }

  var mascotStage: MascotStage { MascotStage.stage(forEarned: earned) }

  func isUnlocked(_ item: RewardItem) -> Bool {
    item.cost == 0 || unlockedIDs.contains(item.id)
  }

  func canAfford(_ item: RewardItem) -> Bool {
    balance >= item.cost
  }
}

extension Color {
  /// Star colour: amber on light backgrounds, Apple yellow on dark ones.
  static let star = Color(light: 0xE09A00, dark: 0xFFD60A)
}
