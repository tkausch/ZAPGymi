import SwiftData
import SwiftUI

struct SettingsView: View {
  @AppStorage(SettingsKey.track) private var trackRaw = ""
  @AppStorage(SettingsKey.examDate) private var examDateValue: Double = 0
  @AppStorage(SettingsKey.theme) private var themeRaw = AppTheme.standard.rawValue
  @AppStorage(SettingsKey.appearance) private var appearanceRaw = AppearanceMode.automatic.rawValue
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var confirmsDeletion = false
  @State private var showsExamDate = false

  var body: some View {
    NavigationStack {
      Form {
        Section {
          Picker("Prüfungstyp", selection: $trackRaw) {
            ForEach(ExamTrack.allCases) { track in
              Text(track.title).tag(track.rawValue)
            }
          }
          Button {
            showsExamDate = true
          } label: {
            LabeledContent("Prüfungsdatum") {
              Text(examDateValue > 0
                ? Date(timeIntervalSinceReferenceDate: examDateValue).formatted(date: .long, time: .omitted)
                : "Nicht eingetragen")
            }
          }
          .tint(.primary)
        } header: {
          Text("Prüfung")
        } footer: {
          Text("Dein Fortschritt bleibt erhalten, wenn du den Prüfungstyp wechselst.")
        }

        Section {
          NavigationLink {
            ThemeSettingsView()
          } label: {
            LabeledContent("Farbthema", value: (AppTheme(rawValue: themeRaw) ?? .standard).title)
          }
          Picker("Hell oder dunkel", selection: $appearanceRaw) {
            ForEach(AppearanceMode.allCases) { mode in
              Text(mode.title).tag(mode.rawValue)
            }
          }
        } header: {
          Text("Aussehen")
        } footer: {
          Text("«Automatisch» folgt der Einstellung deines Geräts, zum Beispiel am Abend im Dunkelmodus.")
        }

        Section {
          Button("Alle Daten löschen", role: .destructive) {
            confirmsDeletion = true
          }
        } header: {
          Text("Daten")
        } footer: {
          Text("Profil, Fortschritt, gemerkte Aufgaben, Aufsätze und Simulationen sind nur auf diesem Gerät gespeichert. Wenn du die App löschst oder das Gerät wechselst, gehen sie verloren.")
        }

        Section("Über") {
          Text("Aufgaben der Zentralen Aufnahmeprüfung (ZAP) des Kantons Zürich, 2015 bis 2025.")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
      .themedBackground()
      .navigationTitle("Einstellungen")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Fertig") { dismiss() }
        }
      }
      .sheet(isPresented: $showsExamDate) {
        ExamDateSheet()
      }
      .confirmationDialog("Alle Daten löschen?", isPresented: $confirmsDeletion, titleVisibility: .visible) {
        Button("Alles löschen", role: .destructive, action: deleteAll)
      } message: {
        Text("Profil, Fortschritt, gemerkte Aufgaben, Aufsätze und Simulationen werden gelöscht. Das lässt sich nicht rückgängig machen.")
      }
    }
    // An open sheet does not pick up tint changes from the app, so apply the theme here too.
    .environment(\.appTheme, AppTheme(rawValue: themeRaw) ?? .standard)
    .tint((AppTheme(rawValue: themeRaw) ?? .standard).accent)
  }

  private func deleteAll() {
    try? modelContext.delete(model: Attempt.self)
    try? modelContext.delete(model: EssayDraft.self)
    try? modelContext.delete(model: ExamSession.self)
    try? modelContext.delete(model: SavedTask.self)
    try? modelContext.save()
    examDateValue = 0
    themeRaw = AppTheme.standard.rawValue
    appearanceRaw = AppearanceMode.automatic.rawValue
    dismiss()
    trackRaw = ""
  }
}
