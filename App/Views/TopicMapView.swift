import SwiftUI

/// The exam areas as tiles, filled more strongly the further the child has come.
/// Every tile also names its stage with text and a symbol, so colour is never the only cue.
struct TopicMapView: View {
  var progress: [AreaProgress]
  var onSelect: (LearningArea) -> Void

  private let columns = [GridItem(.adaptive(minimum: 150), spacing: 10)]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 10) {
      ForEach(progress) { area in
        // Buttons instead of navigation links: inside a list row, links would each get a disclosure arrow.
        Button {
          onSelect(area.area)
        } label: {
          AreaTile(progress: area)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Zeigt die Aufgaben dieses Bereichs")
      }
    }
  }
}

private struct AreaTile: View {
  var progress: AreaProgress
  @Environment(\.appTheme) private var theme

  private var isFilled: Bool { progress.stage == .gemeistert }

  private var fill: AnyShapeStyle {
    switch progress.stage {
    case .neu: AnyShapeStyle(Color.clear)
    case .wirdSicherer: AnyShapeStyle(theme.accent.opacity(0.15))
    case .sicher: AnyShapeStyle(theme.accent.opacity(0.4))
    case .gemeistert: AnyShapeStyle(theme.accent)
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Image(systemName: progress.area.systemImage)
        .font(.title3)
      Text(progress.area.title)
        .font(.subheadline.weight(.semibold))
        .lineLimit(2, reservesSpace: true)
        .multilineTextAlignment(.leading)
      Label(progress.stage.title, systemImage: progress.stage.systemImage)
        .font(.caption.weight(.medium))
      Text("\(progress.attempted) von \(progress.total) gelöst")
        .font(.caption2)
        .opacity(0.8)
    }
    .foregroundStyle(isFilled ? AnyShapeStyle(theme.onAccent) : AnyShapeStyle(.primary))
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    // The stage colour sits on an opaque tile, so its tint looks the same on every theme background.
    .background(fill, in: .rect(cornerRadius: 14))
    .background(.background, in: .rect(cornerRadius: 14))
    .overlay {
      if progress.stage == .neu {
        RoundedRectangle(cornerRadius: 14)
          .strokeBorder(Color.secondary.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
      }
    }
    .contentShape(.rect(cornerRadius: 14))
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(progress.area.title), \(progress.stage.title), \(progress.attempted) von \(progress.total) gelöst")
  }
}
