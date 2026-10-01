import SwiftUI

struct ActivityRing: Identifiable {
  var id: String
  var progress: Double
  var color: Color
}

/// Concentric progress rings, outermost first, on a black disc like the Apple Watch activity rings.
struct ActivityRings: View {
  var rings: [ActivityRing]
  var lineWidth: CGFloat = 13
  var spacing: CGFloat = 3
  var discPadding: CGFloat = 8
  @State private var appeared = false

  var body: some View {
    ZStack {
      Circle()
        .fill(.black)
      ForEach(Array(rings.enumerated()), id: \.element.id) { index, ring in
        let inset = CGFloat(index) * (lineWidth + spacing) + lineWidth / 2
        ZStack {
          Circle()
            .stroke(ring.color.opacity(0.25), lineWidth: lineWidth)
          Circle()
            .trim(from: 0, to: appeared ? min(max(ring.progress, 0), 1) : 0)
            .stroke(ring.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
        }
        .padding(inset + discPadding)
      }
    }
    .aspectRatio(1, contentMode: .fit)
    .onAppear {
      withAnimation(.smooth(duration: 0.8)) { appeared = true }
    }
    .accessibilityHidden(true)
  }
}
