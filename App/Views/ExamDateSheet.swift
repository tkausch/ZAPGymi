import SwiftUI

/// Lets the child enter, change or remove the date of the exam.
struct ExamDateSheet: View {
  @AppStorage(SettingsKey.examDate) private var examDateValue: Double = 0
  @Environment(\.dismiss) private var dismiss
  @State private var selection = Date.now

  private var tomorrow: Date {
    let calendar = Calendar.current
    return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: .now)) ?? .now
  }

  private var hasStoredDate: Bool { examDateValue > 0 }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          DatePicker("Prüfungsdatum", selection: $selection, in: tomorrow..., displayedComponents: .date)
            .datePickerStyle(.graphical)
        } footer: {
          Text("Die Startseite zeigt dir, wie viele Tage bis zur Prüfung bleiben. Das Datum steht in der Einladung zur Aufnahmeprüfung.")
        }

        if hasStoredDate {
          Section {
            Button("Datum entfernen", role: .destructive) {
              examDateValue = 0
              dismiss()
            }
          }
        }
      }
      .navigationTitle("Prüfungsdatum")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Abbrechen") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Sichern") {
            examDateValue = Calendar.current.startOfDay(for: selection).timeIntervalSinceReferenceDate
            dismiss()
          }
        }
      }
      .onAppear {
        let stored = Date(timeIntervalSinceReferenceDate: examDateValue)
        selection = hasStoredDate && stored >= tomorrow ? stored : tomorrow
      }
    }
  }
}
