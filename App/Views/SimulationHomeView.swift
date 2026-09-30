import SwiftData
import SwiftUI

struct SimulationHomeView: View {
  var track: ExamTrack
  @Environment(\.catalog) private var catalog
  @Query(sort: \ExamSession.startDate, order: .reverse) private var allSessions: [ExamSession]
  @Query private var attempts: [Attempt]
  @State private var activeSession: ExamSession?

  private var sessions: [ExamSession] {
    allSessions.filter { $0.track == track }
  }

  var body: some View {
    let openSessions = sessions.filter { $0.state == .running || $0.state == .awaitingGrading }
    let finished = sessions.filter { $0.state == .graded || $0.state == .cancelled }

    NavigationStack {
      List {
        if !openSessions.isEmpty {
          Section("Offen") {
            ForEach(openSessions) { session in
              Button {
                activeSession = session
              } label: {
                LabeledContent {
                  Text(session.state == .running ? "Fortsetzen" : "Auswerten")
                } label: {
                  Label("\(session.subject.title) \(String(session.year))", systemImage: session.state == .running ? "timer" : "checklist")
                }
              }
            }
          }
        }

        Section {
          ForEach(Subject.gradable) { subject in
            NavigationLink {
              SimulationStartView(track: track, subject: subject, isBlocked: !openSessions.isEmpty) { session in
                activeSession = session
              }
            } label: {
              LabeledContent {
                Text("\(track.minutes(for: subject)) Min.")
              } label: {
                Label(subject.title, systemImage: subject.systemImage)
              }
            }
          }
        } header: {
          Text("Neue Simulation")
        } footer: {
          Text("Du löst ein Fach eines früheren Jahrgangs mit der Originalzeit auf Papier. Die Lösungen sind gesperrt, bis du abgibst. Den Aufsatz übst du unter «Aufgaben» mit Timer.")
        }

        if !finished.isEmpty {
          Section("Bisherige Simulationen") {
            ForEach(finished) { session in
              if session.state == .graded {
                NavigationLink {
                  SimulationResultView(session: session)
                } label: {
                  SessionRow(session: session, result: result(of: session))
                }
              } else {
                SessionRow(session: session, result: nil)
              }
            }
          }
        }
      }
      .navigationTitle("Prüfung")
      .fullScreenCover(item: $activeSession) { session in
        SimulationRunView(session: session)
      }
    }
  }

  private func result(of session: ExamSession) -> (points: Int, max: Int)? {
    let sessionAttempts = attempts.filter { $0.sessionID == session.id }
    let max = sessionAttempts.compactMap(\.maxPoints).reduce(0, +)
    guard max > 0 else { return nil }
    return (sessionAttempts.compactMap(\.points).reduce(0, +), max)
  }
}

private struct SessionRow: View {
  var session: ExamSession
  var result: (points: Int, max: Int)?

  var body: some View {
    LabeledContent {
      if session.state == .cancelled {
        Text("Abgebrochen")
      } else if let result {
        Text("\(result.points) / \(result.max) P.")
          .monospacedDigit()
      } else {
        Text("Ausgewertet")
      }
    } label: {
      VStack(alignment: .leading, spacing: 2) {
        Text("\(session.subject.title) \(String(session.year))")
        Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}

struct SimulationStartView: View {
  var track: ExamTrack
  var subject: Subject
  var isBlocked: Bool
  var onStart: (ExamSession) -> Void
  @Environment(\.catalog) private var catalog
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var selectedYear: Int?

  var body: some View {
    List {
      Section {
        Label("\(track.minutes(for: subject)) Minuten, wie an der Prüfung", systemImage: "clock")
        Text(track.allowedAids(for: subject))
          .font(.subheadline)
        Label("Die Zeit läuft weiter, auch wenn du die App schliesst.", systemImage: "info.circle")
          .font(.subheadline)
      }

      if isBlocked {
        Section {
          Text("Beende oder werte zuerst die offene Simulation aus.")
            .foregroundStyle(.secondary)
        }
      }

      Section("Jahrgang wählen") {
        ForEach(catalog.years(for: track, subject: subject), id: \.self) { year in
          let hasExam = PDFLibrary.url(year: year, track: track, subject: subject, kind: .aufgaben) != nil
          let hasSolution = PDFLibrary.url(year: year, track: track, subject: subject, kind: .loesungen) != nil
          let hasText = subject != .sprache || PDFLibrary.url(year: year, track: track, subject: subject, kind: .textblatt) != nil
          Button {
            selectedYear = year
          } label: {
            VStack(alignment: .leading, spacing: 2) {
              Text(String(year))
              Group {
                if !hasExam {
                  Text("Prüfungsheft fehlt")
                } else if !hasText {
                  Text("Textblatt fehlt")
                } else if !hasSolution {
                  Text("Ohne offizielle Lösung")
                }
              }
              .font(.caption)
              .foregroundStyle(.secondary)
            }
          }
          .tint(.primary)
          .disabled(!hasExam || !hasText || isBlocked)
        }
      }
    }
    .navigationTitle(subject.title)
    .alert(
      "Simulation starten?",
      isPresented: Binding(get: { selectedYear != nil }, set: { if !$0 { selectedYear = nil } }),
      presenting: selectedYear
    ) { year in
      Button("Starten") { start(year: year) }
      Button("Abbrechen", role: .cancel) {}
    } message: { year in
      Text("\(subject.title) \(String(year)): \(track.minutes(for: subject)) Minuten. Leg Papier und Stifte bereit. Die Zeit startet sofort.")
    }
  }

  private func start(year: Int) {
    let session = ExamSession(
      year: year,
      track: track,
      subject: subject,
      durationSeconds: Double(track.minutes(for: subject) * 60)
    )
    modelContext.insert(session)
    dismiss()
    onStart(session)
  }
}
