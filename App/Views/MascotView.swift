import SwiftUI

/// Pico, the mascot, in its current stage and with the accessories it wears.
struct MascotView: View {
  var stage: MascotStage
  var head: MascotAccessory?
  var face: MascotAccessory?
  var size: CGFloat = 120

  var body: some View {
    ZStack {
      Circle()
        .fill(.tint.opacity(0.15))
      Image(systemName: stage.systemImage)
        .font(.system(size: size * stage.scale * 0.8))
        .foregroundStyle(.tint)
      if let face {
        Image(systemName: face.systemImage)
          .font(.system(size: size * stage.scale * 0.22, weight: .bold))
          .foregroundStyle(.primary)
          .offset(stage == .ei
            ? CGSize(width: 0, height: -size * 0.06)
            : CGSize(width: -size * stage.scale * 0.2, height: -size * stage.scale * 0.17))
      }
      if let head {
        Image(systemName: head.systemImage)
          .font(.system(size: size * stage.scale * 0.3))
          .foregroundStyle(head == .krone ? AnyShapeStyle(Color.star) : AnyShapeStyle(.primary))
          .offset(stage == .ei
            ? CGSize(width: 0, height: -size * 0.28)
            : CGSize(width: -size * stage.scale * 0.2, height: -size * stage.scale * 0.42))
      }
    }
    .frame(width: size, height: size)
    .accessibilityElement()
    .accessibilityLabel(accessibilityText)
  }

  private var accessibilityText: String {
    var text = "\(MascotStage.mascotName), \(stage.title)"
    let worn = [head, face].compactMap { $0?.title }
    if !worn.isEmpty {
      text += ", trägt \(worn.formatted(.list(type: .and)))"
    }
    return text
  }
}

/// The mascot with the accessories stored in the settings.
struct WornMascotView: View {
  var stage: MascotStage
  var size: CGFloat = 120
  @AppStorage(MascotAccessory.Slot.head.settingsKey) private var headRaw = ""
  @AppStorage(MascotAccessory.Slot.face.settingsKey) private var faceRaw = ""

  var body: some View {
    MascotView(stage: stage, head: MascotAccessory(rawValue: headRaw), face: MascotAccessory(rawValue: faceRaw), size: size)
  }
}
