import SwiftData
import SwiftUI

struct SimulationRunView: View {
  @Bindable var session: ExamSession
  @Environment(\.catalog) private var catalog
  @Environment(\.dismiss) private var dismiss
  @State private var now = Date.now
  @State private var document = ExamDocumentKind.aufgaben
  @State private var confirmsSubmit = false
  @State private var confirmsCancel = false

  var body: some View {
    NavigationStack {
      Group {
        switch session.state {
        case .running:
          examView
        case .awaitingGrading:
          SimulationGradingView(session: session)
        case .graded:
          SimulationResultView(session: session)
        case .cancelled:
          ContentUnavailableView("Simulation abgebrochen", systemImage: "xmark.circle", description: Text("Sie zählt nicht in deine Statistik."))
        }
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Schliessen", systemImage: "chevron.down") { dismiss() }
            .accessibilityHint(session.state == .running ? "Die Zeit läuft weiter" : "")
        }
      }
    }
    .task {
      while !Task.isCancelled {
        now = .now
        if session.state == .running && now >= session.endDate {
          session.finishedAt = session.endDate
        }
        try? await Task.sleep(for: .seconds(1))
      }
    }
    .interactiveDismissDisabled()
  }

  private var firstTask: ExamTask? {
    catalog.tasks(for: session.track, subject: session.subject, year: session.year).first
  }

  @ViewBuilder
  private var examView: some View {
    VStack(spacing: 0) {
      if session.subject == .sprache {
        Picker("Dokument", selection: $document) {
          Text("Aufgaben").tag(ExamDocumentKind.aufgaben)
          Text("Textblatt").tag(ExamDocumentKind.textblatt)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
      }
      if let task = firstTask {
        ExamDocumentView(task: task, kind: document)
      }
    }
    .safeAreaInset(edge: .bottom) {
      Button {
        confirmsSubmit = true
      } label: {
        Text("Abgeben")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .padding()
      .background(.bar)
    }
    .navigationTitle("\(session.subject.title) \(String(session.year))")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        let remaining = session.endDate.timeIntervalSince(now)
        Text(TimeFormatting.clock(remaining))
          .font(.headline.monospacedDigit())
          .foregroundStyle(remaining < 300 ? AnyShapeStyle(.orange) : AnyShapeStyle(.primary))
          .accessibilityLabel("Restzeit \(TimeFormatting.minutes(remaining))")
      }
      ToolbarItem(placement: .topBarTrailing) {
        Menu("Mehr", systemImage: "ellipsis") {
          Button("Simulation abbrechen", systemImage: "xmark", role: .destructive) {
            confirmsCancel = true
          }
        }
      }
    }
    .alert("Jetzt abgeben?", isPresented: $confirmsSubmit) {
      Button("Abgeben") { session.finishedAt = .now }
      Button("Weiterarbeiten", role: .cancel) {}
    } message: {
      Text("Danach vergleichst du deine Lösungen mit dem Korrekturschema und trägst deine Punkte ein.")
    }
    .alert("Simulation abbrechen?", isPresented: $confirmsCancel) {
      Button("Abbrechen", role: .destructive) {
        session.cancelledAt = .now
        dismiss()
      }
      Button("Weiterarbeiten", role: .cancel) {}
    } message: {
      Text("Die Simulation wird als abgebrochen gespeichert und zählt nicht in die Statistik.")
    }
  }
}
