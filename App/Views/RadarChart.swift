import SwiftUI

/// One axis of the radar chart.
struct RadarAxis: Identifiable {
  var label: String
  /// Share of points reached, from 0 to 1.
  var value: Double
  /// Few results: drawn as a hollow point, because the value is not reliable yet.
  var isTentative: Bool
  /// Not practised yet: no point, so it does not look like a result of 0 %.
  var isOpen: Bool

  var id: String { label }
}

/// A spider chart with one series, grid rings at 25 % steps and labels around the outside.
struct RadarChart: View {
  var axes: [RadarAxis]
  var color: Color

  private let rings: [Double] = [0.25, 0.5, 0.75, 1]
  private let labelWidth: CGFloat = 86

  var body: some View {
    GeometryReader { proxy in
      let size = min(proxy.size.width, proxy.size.height)
      let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
      let radius = max(size / 2 - 52, 20)

      ZStack {
        // Recessive grid: rings and spokes.
        ForEach(rings, id: \.self) { ring in
          polygon(values: Array(repeating: ring, count: axes.count), center: center, radius: radius)
            .stroke(Color.secondary.opacity(ring == 1 ? 0.45 : 0.2), lineWidth: 1)
        }
        Path { path in
          for index in axes.indices {
            path.move(to: center)
            path.addLine(to: point(index: index, value: 1, center: center, radius: radius))
          }
        }
        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)

        // The data.
        polygon(values: axes.map(\.value), center: center, radius: radius)
          .fill(color.opacity(0.22))
        polygon(values: axes.map(\.value), center: center, radius: radius)
          .stroke(color, style: StrokeStyle(lineWidth: 2, lineJoin: .round))

        ForEach(Array(axes.enumerated()), id: \.element.id) { index, axis in
          let location = point(index: index, value: axis.value, center: center, radius: radius)
          Circle()
            .fill(axis.isTentative ? AnyShapeStyle(.background) : AnyShapeStyle(color))
            .overlay {
              Circle().stroke(color, lineWidth: 2)
            }
            .frame(width: 9, height: 9)
            .background(Circle().fill(.background).frame(width: 13, height: 13))
            .opacity(axis.isOpen ? 0 : 1)
            .position(location)

          Text(axis.isOpen ? "\(axis.label)\nnoch offen" : axis.label)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.8)
            .frame(width: labelWidth)
            .position(labelPosition(index: index, center: center, radius: radius))
        }
      }
    }
    .aspectRatio(1, contentMode: .fit)
  }

  private func angle(for index: Int) -> Double {
    -Double.pi / 2 + Double(index) / Double(max(axes.count, 1)) * 2 * Double.pi
  }

  private func point(index: Int, value: Double, center: CGPoint, radius: CGFloat) -> CGPoint {
    let angle = angle(for: index)
    let distance = radius * CGFloat(min(max(value, 0), 1))
    return CGPoint(x: center.x + cos(angle) * distance, y: center.y + sin(angle) * distance)
  }

  private func labelPosition(index: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
    let angle = angle(for: index)
    let distance = radius + 26
    return CGPoint(x: center.x + cos(angle) * distance, y: center.y + sin(angle) * distance)
  }

  private func polygon(values: [Double], center: CGPoint, radius: CGFloat) -> Path {
    Path { path in
      for (index, value) in values.enumerated() {
        let location = point(index: index, value: value, center: center, radius: radius)
        if index == 0 { path.move(to: location) } else { path.addLine(to: location) }
      }
      path.closeSubpath()
    }
  }
}
