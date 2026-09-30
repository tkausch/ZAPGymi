import SwiftUI

struct OnboardingView: View {
  var onSelect: (ExamTrack) -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: 28) {
        VStack(spacing: 12) {
          Image(systemName: "graduationcap.fill")
            .font(.system(size: 56))
            .foregroundStyle(.tint)
            .accessibilityHidden(true)
          Text("Gymi Trainer")
            .font(.largeTitle.bold())
          Text("Üben mit echten Aufnahmeprüfungen des Kantons Zürich")
            .font(.title3)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.top, 40)

        VStack(alignment: .leading, spacing: 12) {
          Text("Für welche Prüfung übst du?")
            .font(.headline)
          ForEach(ExamTrack.allCases) { track in
            Button {
              onSelect(track)
            } label: {
              HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                  Text(track.title)
                    .font(.headline)
                  Text(track.audience)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.forward")
                  .foregroundStyle(.tertiary)
                  .accessibilityHidden(true)
              }
              .padding()
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(.background.secondary, in: .rect(cornerRadius: 16))
              .contentShape(.rect(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .accessibilityHint("Zeigt nur Aufgaben dieser Prüfung")
          }
          Text("Du kannst das später in den Einstellungen ändern.")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }

        Label("Kein Konto nötig. Alles bleibt auf diesem Gerät.", systemImage: "lock")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
      .padding(24)
      .frame(maxWidth: 560)
      .frame(maxWidth: .infinity)
    }
  }
}
