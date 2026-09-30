import SwiftData
import SwiftUI

/// Lets the child grade their own answer after comparing it with the solution.
struct GradingSheet: View {
  var task: ExamTask
  var onSave: (Outcome) -> Void
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var points = 0
  @State private var outcome = Outcome.richtig
  @State private var hasWrittenSolutionPath = false

  var body: some View {
    NavigationStack {
      Form {
        if let maxPoints = task.maxPoints {
          Section {
            Stepper(value: $points, in: 0...maxPoints) {
              Text("\(points) von \(maxPoints) Punkten")
                .font(.headline)
            }
          } footer: {
            Text(rulesText)
          }

          if task.subject == .mathematik && points == maxPoints {
            Section {
              Toggle("Mein Lösungsweg steht auf dem Papier", isOn: $hasWrittenSolutionPath)
            } footer: {
              Text(task.track == .langzeit
                ? "An der Prüfung gibt ein richtiges Resultat ohne verständlichen Lösungsweg 0 Punkte. Fehlt die Einheit, wird 1 Punkt abgezogen."
                : "Ohne ersichtlichen Lösungsweg gibt es an der Prüfung nicht die volle Punktzahl.")
            }
          }
        } else {
          Section {
            Picker("Ergebnis", selection: $outcome) {
              ForEach(Outcome.allCases) { outcome in
                Text(outcome.title).tag(outcome)
              }
            }
            .pickerStyle(.segmented)
          } footer: {
            Text("Für diese Aufgabe sind keine Punkte hinterlegt. \(rulesText)")
          }
        }
      }
      .themedBackground()
      .navigationTitle("Einschätzen")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Abbrechen") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Speichern", action: save)
            .disabled(needsSolutionPathConfirmation)
        }
      }
    }
    .presentationDetents([.medium, .large])
  }

  private var needsSolutionPathConfirmation: Bool {
    task.subject == .mathematik && task.maxPoints == points && !hasWrittenSolutionPath
  }

  private var rulesText: String {
    switch task.subject {
    case .mathematik:
      "Vergleiche Resultat und Lösungsweg mit der Lösung. Gleichwertige Schreibweisen zählen auch."
    case .sprache, .aufsatz:
      "Vergleiche mit den Musterantworten und Korrekturregeln in der Lösung. Andere Formulierungen mit gleichem Inhalt zählen auch."
    }
  }

  private func save() {
    let result: Outcome
    if let maxPoints = task.maxPoints {
      result = Outcome(points: points, maxPoints: maxPoints)
    } else {
      result = outcome
    }
    modelContext.insert(Attempt(
      taskID: task.id,
      points: task.maxPoints == nil ? nil : points,
      maxPoints: task.maxPoints,
      outcome: result
    ))
    onSave(result)
    dismiss()
  }
}
