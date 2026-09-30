import SwiftData
import SwiftUI

struct HomeView: View {
  var track: ExamTrack
  @Binding var selectedTab: AppTab
  @Environment(\.catalog) private var catalog
  @Query(sort: \Attempt.date) private var attempts: [Attempt]
  @Query(sort: \EssayDraft.updatedAt, order: .reverse) private var drafts: [EssayDraft]
  @Query private var sessions: [ExamSession]
  @AppStorage(SettingsKey.examDate) private var examDateValue: Double = 0
  @State private var showsSettings = false
  @State private var showsExamDate = false

  var body: some View {
    let tasks = catalog.tasks(for: track)
    let summary = ProgressSummary(attempts: attempts)
    let reviews = summary.dueReviews(in: tasks)

    NavigationStack {
      List {
        countdownSection

        if let session = sessions.first(where: { $0.track == track && ($0.state == .running || $0.state == .awaitingGrading) }) {
          Section {
            Button {
              selectedTab = .exam
            } label: {
              Label(
                session.state == .running
                  ? "\(session.subject.title) \(String(session.year)) läuft – fortsetzen"
                  : "\(session.subject.title) \(String(session.year)) auswerten",
                systemImage: "timer"
              )
            }
          }
        }

        Section("Vorschlag für heute") {
          if let suggestion = summary.suggestion(from: tasks) {
            NavigationLink(value: suggestion) {
              TaskRow(task: suggestion, status: summary.status(of: suggestion))
            }
          } else {
            Text("Du hast alle Aufgaben gelöst. Stark!")
              .foregroundStyle(.secondary)
          }
        }

        if let draft = openDraft, let task = catalog.task(id: draft.taskID) {
          Section("Aufsatz") {
            NavigationLink(value: task) {
              Label(draft.finishedAt == nil ? "Weiterschreiben: \(task.displayTitle)" : "Einschätzen: \(task.displayTitle)", systemImage: "pencil.line")
            }
          }
        }

        Section("Üben") {
          NavigationLink(value: TaskListRoute.reviews(track)) {
            LabeledContent {
              Text(reviews.count, format: .number)
            } label: {
              Label("Zu wiederholen", systemImage: "arrow.counterclockwise")
            }
          }

          NavigationLink(value: TaskListRoute.weaknesses(track)) {
            Label("Schwächen üben", systemImage: "target")
          }
        }

        Section("Diese Woche") {
          let days = summary.practiceDaysThisWeek()
          VStack(alignment: .leading, spacing: 8) {
            Text("\(days) von \(ProgressSummary.weeklyGoal) Übungstagen")
              .font(.headline)
            ProgressView(value: Double(min(days, ProgressSummary.weeklyGoal)), total: Double(ProgressSummary.weeklyGoal))
            Text(weekMessage(days: days))
              .font(.footnote)
              .foregroundStyle(.secondary)
          }
          .accessibilityElement(children: .combine)
        }
      }
      .themedBackground()
      .navigationTitle("Heute")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Einstellungen", systemImage: "gearshape") {
            showsSettings = true
          }
        }
      }
      .sheet(isPresented: $showsSettings) {
        SettingsView()
      }
      .sheet(isPresented: $showsExamDate) {
        ExamDateSheet()
      }
      .examTaskDestinations()
    }
  }

  private var openDraft: EssayDraft? {
    drafts.first { draft in
      draft.assessedAt == nil && catalog.task(id: draft.taskID)?.track == track
    }
  }

  @ViewBuilder
  private var countdownSection: some View {
    Section {
      if examDateValue > 0 {
        let examDate = Date(timeIntervalSinceReferenceDate: examDateValue)
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: calendar.startOfDay(for: examDate)).day ?? 0
        if days > 0 {
          Button {
            showsExamDate = true
          } label: {
            VStack(alignment: .leading, spacing: 4) {
              Text(days == 1 ? "Noch 1 Tag" : "Noch \(days) Tage")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
              Text("bis zur Prüfung am \(examDate.formatted(date: .long, time: .omitted))")
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
          }
          .buttonStyle(.plain)
          .accessibilityElement(children: .combine)
          .accessibilityHint("Prüfungsdatum ändern")
        } else if days == 0 {
          Text("Heute ist Prüfung. Viel Erfolg!")
            .font(.title2.bold())
        } else {
          VStack(alignment: .leading, spacing: 8) {
            Text("Das Prüfungsdatum ist vorbei.")
              .font(.headline)
            Button("Neues Datum eintragen oder entfernen") {
              showsExamDate = true
            }
          }
        }
      } else {
        Button {
          showsExamDate = true
        } label: {
          Label("Prüfungsdatum eintragen", systemImage: "calendar")
        }
      }
    }
  }

  private func weekMessage(days: Int) -> String {
    if days >= ProgressSummary.weeklyGoal {
      return track.usesSimpleLanguage ? "Toll, du hast dein Wochenziel erreicht!" : "Wochenziel erreicht."
    }
    if days == 0 {
      return track.usesSimpleLanguage ? "Heute ist ein guter Tag zum Üben. Schon eine Aufgabe zählt." : "Schon eine Aufgabe zählt als Übungstag."
    }
    return track.usesSimpleLanguage ? "Weiter so! Jede Aufgabe zählt." : "Jede Aufgabe zählt als Übungstag."
  }
}
