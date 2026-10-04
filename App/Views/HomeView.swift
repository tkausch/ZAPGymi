import SwiftData
import SwiftUI

struct HomeView: View {
  var track: ExamTrack
  @Binding var selectedTab: AppTab
  @Environment(\.catalog) private var catalog
  @Query(sort: \Attempt.date) private var attempts: [Attempt]
  @Query(sort: \EssayDraft.updatedAt, order: .reverse) private var drafts: [EssayDraft]
  @Query private var sessions: [ExamSession]
  @Query(sort: \SavedTask.savedAt, order: .reverse) private var saved: [SavedTask]
  @Query private var awards: [StarAward]
  @Query private var unlocks: [UnlockedReward]
  @AppStorage(SettingsKey.examDate) private var examDateValue: Double = 0
  @State private var showsSettings = false
  @State private var showsExamDate = false
  @State private var showsWeeklyGoals = false

  var body: some View {
    let tasks = catalog.tasks(for: track)
    let summary = ProgressSummary(attempts: attempts)
    let reviewCount = summary.dueReviews(in: tasks).count
    let savedCount = SavedTasksView.savedTasks(saved, catalog: catalog, track: track).count

    NavigationStack {
      List {
        Section {
          WeeklyGoalsCard(track: track)
          starsRow
        } header: {
          HStack {
            Text("Wochenziele")
            Spacer()
            Button("Anpassen") { showsWeeklyGoals = true }
              .font(.subheadline)
              .textCase(nil)
          }
        }

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
          ForEach(Subject.gradable) { subject in
            if let suggestion = summary.suggestion(from: tasks, subject: subject) {
              NavigationLink(value: suggestion) {
                VStack(alignment: .leading, spacing: 6) {
                  Label(subject.title, systemImage: subject.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                  TaskRow(task: suggestion, status: summary.status(of: suggestion))
                }
              }
            } else {
              Label("\(subject.title): alle Aufgaben gelöst. Stark!", systemImage: "checkmark.seal")
                .foregroundStyle(.secondary)
            }
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
              Text(reviewCount, format: .number)
            } label: {
              Label("Zu wiederholen", systemImage: "arrow.counterclockwise")
            }
          }

          NavigationLink(value: TaskListRoute.saved(track)) {
            LabeledContent {
              Text(savedCount, format: .number)
            } label: {
              Label("Gemerkte Aufgaben", systemImage: "bookmark")
            }
          }

          NavigationLink(value: TaskListRoute.weaknesses(track)) {
            Label("Schwächen üben", systemImage: "target")
          }

          NavigationLink(value: TaskListRoute.strengths(track)) {
            Label("Meine Stärken", systemImage: "star")
          }
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
      .sheet(isPresented: $showsWeeklyGoals) {
        WeeklyGoalsSheet()
      }
      .navigationDestination(for: HomeRoute.self) { route in
        switch route {
        case .rewards: RewardsView()
        }
      }
      .examTaskDestinations()
    }
  }

  private var starsRow: some View {
    let wallet = StarWallet(awards: awards, unlocks: unlocks)
    return NavigationLink(value: HomeRoute.rewards) {
      HStack(spacing: 12) {
        WornMascotView(stage: wallet.mascotStage, size: 44)
        VStack(alignment: .leading, spacing: 2) {
          Text("Sterne und Belohnungen")
            .font(.subheadline.weight(.semibold))
          Text("\(MascotStage.mascotName) ist ein \(wallet.mascotStage.title)")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        Spacer(minLength: 8)
        Label("\(wallet.balance)", systemImage: "star.fill")
          .font(.headline.monospacedDigit())
          .labelStyle(StarLabelStyle())
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Sterne und Belohnungen, \(wallet.balance) Sterne")
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
            HStack {
              Label(days == 1 ? "Noch 1 Tag bis zur Prüfung" : "Noch \(days) Tage bis zur Prüfung", systemImage: "calendar")
                .font(.subheadline)
                .foregroundStyle(.primary)
              Spacer(minLength: 8)
              Text(examDate.formatted(date: .abbreviated, time: .omitted))
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .contentShape(.rect)
          }
          .buttonStyle(.plain)
          .accessibilityElement(children: .combine)
          .accessibilityHint("Prüfungsdatum ändern")
        } else if days == 0 {
          Label("Heute ist Prüfung. Viel Erfolg!", systemImage: "star")
            .font(.subheadline.bold())
        } else {
          VStack(alignment: .leading, spacing: 8) {
            Text("Das Prüfungsdatum ist vorbei.")
              .font(.subheadline)
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
            .font(.subheadline)
        }
      }
    }
  }
}

enum HomeRoute: Hashable {
  case rewards
}
