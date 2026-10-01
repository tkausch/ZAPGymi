import SwiftUI

struct TipsView: View {
  var track: ExamTrack

  var body: some View {
    NavigationStack {
      List {
        Section(track.title) {
          ForEach(LearningTip.tips(for: track)) { tip in
            TipRow(tip: tip)
          }
        }

        Section("Für alle") {
          ForEach(LearningTip.general) { tip in
            TipRow(tip: tip)
          }
        }
      }
      .themedBackground()
      .navigationTitle("Tipps")
    }
  }
}

private struct TipRow: View {
  var tip: LearningTip

  var body: some View {
    Label {
      VStack(alignment: .leading, spacing: 4) {
        Text(tip.title)
          .font(.headline)
        Text(tip.text)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    } icon: {
      Image(systemName: tip.systemImage)
        .foregroundStyle(.tint)
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
  }
}
