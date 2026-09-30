import SwiftData
import SwiftUI

struct SettingsView: View {
  @AppStorage(SettingsKey.track) private var trackRaw = ""
  @AppStorage(SettingsKey.examDate) private var examDateValue: Double = 0
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var confirmsDeletion = false

  private var tomorrow: Date {
    Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: .now)) ?? .now
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          Picker("Prüfungstyp", selection: $trackRaw) {
            ForEach(ExamTrack.allCases) { track in
              Text(track.title).tag(track.rawValue)
            }
          }
          Toggle("Prüfungsdatum", isOn: hasExamDate)
          if examDateValue > 0 {
            DatePicker("Datum", selection: examDate, in: tomorrow..., displayedComponents: .date)
          }
        } header: {
          Text("Prüfung")
        } footer: {
          Text("Dein Fortschritt bleibt erhalten, wenn du den Prüfungstyp wechselst.")
        }

        Section {
          Button("Alle Daten löschen", role: .destructive) {
            confirmsDeletion = true
          }
        } header: {
          Text("Daten")
        } footer: {
          Text("Profil, Fortschritt, Aufsätze und Simulationen sind nur auf diesem Gerät gespeichert. Wenn du die App löschst oder das Gerät wechselst, gehen sie verloren.")
        }

        Section("Über") {
          Text("Aufgaben der Zentralen Aufnahmeprüfung (ZAP) des Kantons Zürich, 2015 bis 2025.")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
      .navigationTitle("Einstellungen")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Fertig") { dismiss() }
        }
      }
      .confirmationDialog("Alle Daten löschen?", isPresented: $confirmsDeletion, titleVisibility: .visible) {
        Button("Alles löschen", role: .destructive, action: deleteAll)
      } message: {
        Text("Profil, Fortschritt, Aufsätze und Simulationen werden gelöscht. Das lässt sich nicht rückgängig machen.")
      }
    }
  }

  private var hasExamDate: Binding<Bool> {
    Binding {
      examDateValue > 0
    } set: { isOn in
      examDateValue = isOn ? Calendar.current.date(byAdding: .month, value: 3, to: .now)!.timeIntervalSinceReferenceDate : 0
    }
  }

  private var examDate: Binding<Date> {
    Binding {
      Date(timeIntervalSinceReferenceDate: examDateValue)
    } set: { date in
      examDateValue = date.timeIntervalSinceReferenceDate
    }
  }

  private func deleteAll() {
    try? modelContext.delete(model: Attempt.self)
    try? modelContext.delete(model: EssayDraft.self)
    try? modelContext.delete(model: ExamSession.self)
    try? modelContext.save()
    examDateValue = 0
    dismiss()
    trackRaw = ""
  }
}
