import SwiftData
import SwiftUI

struct TaskDetailView: View {
  var task: ExamTask
  @Query private var attempts: [Attempt]
  @State private var document = ExamDocumentKind.aufgaben
  @State private var solutionRevealed = false
  @State private var confirmsReveal = false
  @State private var showsGrading = false
  @State private var showsInfo = false
  @State private var feedback: Outcome?

  init(task: ExamTask) {
    self.task = task
    let id = task.id
    _attempts = Query(filter: #Predicate<Attempt> { $0.taskID == id }, sort: \Attempt.date, order: .reverse)
  }

  private var documentTabs: [ExamDocumentKind] {
    var tabs: [ExamDocumentKind] = [.aufgaben]
    if task.subject == .sprache { tabs.append(.textblatt) }
    if solutionRevealed { tabs.append(.loesungen) }
    return tabs
  }

  var body: some View {
    VStack(spacing: 0) {
      if documentTabs.count > 1 {
        Picker("Dokument", selection: $document) {
          ForEach(documentTabs) { kind in
            Text(kind.title).tag(kind)
          }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
      }
      ExamDocumentView(task: task, kind: document)
    }
    .safeAreaInset(edge: .bottom) {
      bottomBar
    }
    .navigationTitle("\(task.displayTitle) · \(String(task.year))")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Details", systemImage: "info") {
          showsInfo = true
        }
      }
    }
    .alert("Bist du fertig?", isPresented: $confirmsReveal) {
      Button("Lösung zeigen") {
        solutionRevealed = true
        document = .loesungen
      }
      Button("Weiterlösen", role: .cancel) {}
    } message: {
      Text(task.track.usesSimpleLanguage
        ? "Schau die Lösung erst an, wenn du die Aufgabe auf Papier gelöst hast."
        : "Öffne die Lösung erst, wenn deine Lösung auf Papier steht.")
    }
    .sheet(isPresented: $showsGrading) {
      GradingSheet(task: task) { outcome in
        feedback = outcome
      }
    }
    .sheet(isPresented: $showsInfo) {
      TaskInfoSheet(task: task, attempts: attempts)
    }
    .onAppear {
      if !attempts.isEmpty { solutionRevealed = true }
    }
    .sensoryFeedback(.success, trigger: feedback) { _, new in new == .richtig }
  }

  private var bottomBar: some View {
    VStack(alignment: .leading, spacing: 10) {
      if let feedback {
        Label(feedback.feedback(for: task.track), systemImage: feedback.systemImage)
          .font(.subheadline)
      } else if let latest = attempts.first {
        Text(lastResultText(latest))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      } else {
        Text(task.track.allowedAids(for: task.subject))
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      if solutionRevealed {
        Button {
          showsGrading = true
        } label: {
          Text("Selbst einschätzen")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      } else {
        Button {
          confirmsReveal = true
        } label: {
          Text("Fertig – Lösung zeigen")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
    }
    .padding()
    .background(.bar)
  }

  private func lastResultText(_ attempt: Attempt) -> String {
    let date = attempt.date.formatted(date: .abbreviated, time: .omitted)
    if let points = attempt.points, let max = attempt.maxPoints {
      return "Zuletzt am \(date): \(points) von \(max) Punkten"
    }
    return "Zuletzt am \(date): \(attempt.outcome.title)"
  }
}

struct TaskInfoSheet: View {
  var task: ExamTask
  var attempts: [Attempt]
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      Form {
        Section(task.subject == .mathematik ? "Kurzbeschreibung" : "Aufgabe") {
          Text(task.text)
        }
        Section("Details") {
          LabeledContent("Prüfung", value: "\(task.track.title) \(String(task.year))")
          LabeledContent("Thema", value: task.topic)
          if let detail = task.topicDetail {
            LabeledContent("Genauer", value: detail)
          }
          if let difficulty = task.difficulty {
            LabeledContent("Schwierigkeit", value: difficulty.title)
          }
          LabeledContent("Punkte", value: task.maxPoints.map { "\($0)" } ?? "nicht angegeben")
        }
        Section("An der Prüfung") {
          Text(task.track.allowedAids(for: task.subject))
          LabeledContent("Zeit für das ganze Fach", value: "\(task.track.minutes(for: task.subject)) Minuten")
        }
        if !attempts.isEmpty {
          Section("Bisherige Versuche") {
            ForEach(attempts) { attempt in
              LabeledContent(attempt.date.formatted(date: .abbreviated, time: .shortened)) {
                if let points = attempt.points, let max = attempt.maxPoints {
                  Text("\(points) / \(max) P.")
                } else {
                  Text(attempt.outcome.title)
                }
              }
            }
          }
        }
      }
      .navigationTitle(task.displayTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Fertig") { dismiss() }
        }
      }
    }
  }
}
