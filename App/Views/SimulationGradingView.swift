import SwiftData
import SwiftUI

struct SimulationGradingView: View {
  @Bindable var session: ExamSession
  @Environment(\.catalog) private var catalog
  @Environment(\.modelContext) private var modelContext
  @State private var points: [String: Int] = [:]
  @State private var outcomes: [String: Outcome] = [:]
  @State private var shownDocument: ExamDocumentKind?

  private var tasks: [ExamTask] {
    catalog.tasks(for: session.track, subject: session.subject, year: session.year)
  }

  var body: some View {
    List {
      Section {
        Text("Vergleiche jede Aufgabe mit dem Korrekturschema und trag deine Punkte ehrlich ein.")
        HStack {
          Button("Lösung öffnen", systemImage: "doc.text.magnifyingglass") {
            shownDocument = .loesungen
          }
          if session.subject == .sprache {
            Spacer()
            Button("Textblatt", systemImage: "doc.plaintext") {
              shownDocument = .textblatt
            }
          }
        }
        .buttonStyle(.bordered)
      } footer: {
        Text("Benötigte Zeit: \(TimeFormatting.minutes(session.usedSeconds)) von \(TimeFormatting.minutes(session.durationSeconds))")
      }

      Section("Aufgaben") {
        ForEach(tasks) { task in
          if let maxPoints = task.maxPoints {
            Stepper(value: binding(for: task), in: 0...maxPoints) {
              VStack(alignment: .leading, spacing: 2) {
                Text(task.displayTitle)
                Text("\(points[task.id] ?? 0) von \(maxPoints) Punkten · \(task.topic)")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
          } else {
            Picker(selection: outcomeBinding(for: task)) {
              ForEach(Outcome.allCases) { outcome in
                Text(outcome.title).tag(outcome)
              }
            } label: {
              VStack(alignment: .leading, spacing: 2) {
                Text(task.displayTitle)
                Text(task.topic)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
          }
        }
      }

      Section {
        Button(action: save) {
          Text("Auswertung speichern")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
      }
    }
    .navigationTitle("Auswerten")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $shownDocument) { kind in
      if let task = tasks.first {
        DocumentSheet(task: task, kind: kind, title: kind.title)
      }
    }
  }

  private func binding(for task: ExamTask) -> Binding<Int> {
    Binding { points[task.id] ?? 0 } set: { points[task.id] = $0 }
  }

  private func outcomeBinding(for task: ExamTask) -> Binding<Outcome> {
    Binding { outcomes[task.id] ?? .falsch } set: { outcomes[task.id] = $0 }
  }

  private func save() {
    let date = session.finishedAt ?? .now
    for task in tasks {
      if let maxPoints = task.maxPoints {
        let value = points[task.id] ?? 0
        modelContext.insert(Attempt(taskID: task.id, date: date, points: value, maxPoints: maxPoints, outcome: Outcome(points: value, maxPoints: maxPoints), sessionID: session.id))
      } else {
        modelContext.insert(Attempt(taskID: task.id, date: date, points: nil, maxPoints: nil, outcome: outcomes[task.id] ?? .falsch, sessionID: session.id))
      }
    }
    session.gradedAt = .now
  }
}
