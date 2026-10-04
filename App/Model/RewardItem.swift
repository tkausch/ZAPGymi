import Foundation

/// Something the child can unlock with stars.
enum RewardItem: Hashable, Identifiable {
  case theme(AppTheme)
  case accessory(MascotAccessory)

  var id: String {
    switch self {
    case .theme(let theme): "theme.\(theme.rawValue)"
    case .accessory(let accessory): "accessory.\(accessory.rawValue)"
    }
  }

  var title: String {
    switch self {
    case .theme(let theme): "Thema «\(theme.title)»"
    case .accessory(let accessory): accessory.title
    }
  }

  var cost: Int {
    switch self {
    case .theme(let theme): theme.starCost
    case .accessory(let accessory): accessory.starCost
    }
  }
}

extension AppTheme {
  /// The standard theme is free. The child gets the theme chosen at the start for free, too.
  var starCost: Int {
    switch self {
    case .oceanWave: 0
    case .calmPaper: 40
    case .limeZest: 60
    case .sunsetPop: 80
    case .neonNight: 100
    case .galaxy: 120
    }
  }
}
