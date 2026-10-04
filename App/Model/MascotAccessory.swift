import Foundation

/// Something the mascot can wear. It has one place on the head and one in the face.
enum MascotAccessory: String, CaseIterable, Identifiable {
  case brille
  case doktorhut
  case sonnenbrille
  case krone

  var id: String { rawValue }

  var title: String {
    switch self {
    case .brille: "Brille"
    case .doktorhut: "Doktorhut"
    case .sonnenbrille: "Sonnenbrille"
    case .krone: "Krone"
    }
  }

  var systemImage: String {
    switch self {
    case .brille: "eyeglasses"
    case .doktorhut: "graduationcap.fill"
    case .sonnenbrille: "sunglasses.fill"
    case .krone: "crown.fill"
    }
  }

  var slot: Slot {
    switch self {
    case .doktorhut, .krone: .head
    case .brille, .sonnenbrille: .face
    }
  }

  var starCost: Int {
    switch self {
    case .brille: 30
    case .doktorhut: 50
    case .sonnenbrille: 70
    case .krone: 150
    }
  }

  enum Slot: String {
    case head
    case face

    /// Key in UserDefaults for the accessory worn in this place.
    var settingsKey: String { "mascot.\(rawValue)" }
  }
}
