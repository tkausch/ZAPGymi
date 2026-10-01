import SwiftData
import SwiftUI

struct ProgressOverviewView: View {
  var track: ExamTrack
  @Binding var selectedTab: AppTab
  @Environment(\.catalog) private var catalog
  @Environment(\.appTheme) private var theme
  @Query private var attempts: [Attempt]
  @Query(sort: \ExamSession.startDate) private var sessions: [ExamSession]
  @State private var path = NavigationPath()

  /// Assumption: 70 % of the points is a good target for a simulated exam.
  private let examTarget = 0.7
  /// Recommendation: one simulated exam every two weeks.
  private let examInterval: TimeInterval = 14 * 24 * 60 * 60

  var body: some View {
    let tasks = catalog.tasks(for: track)
    let taskIDs = Set(tasks.map(\.id))
    let trackAttempts = attempts.filter { taskIDs.contains($0.taskID) }
    let summary = ProgressSummary(attempts: trackAttempts)
    let areas = summary.areaProgress(for: tasks)

    NavigationStack(path: $path) {
      List {
        Section {
          NavigationLink(value: TaskListRoute.strengths(track)) {
            Label("Meine Stärken", systemImage: "star")
          }
        }

        Section("Gesamtfortschritt") {
          overallProgress(tasks: tasks, summary: summary)
        }

        Section {
          if let next = summary.nextArea(from: areas) {
            nextAreaRow(next, task: summary.nextTask(in: next.area, from: tasks))
          }
          TopicMapView(progress: areas) { area in
            path.append(TaskListRoute.area(track, area))
          }
            .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
            .listRowBackground(Color.clear)
        } header: {
          Text("Themenlandkarte")
        } footer: {
          Text("Neu: noch nicht geübt. Wird sicherer: angefangen. Sicher: mindestens 5 Aufgaben und 60 %. Gemeistert: mindestens 10 Aufgaben und 80 %.")
        }

        Section {
          examHistory
        } header: {
          Text("Probeprüfungs-Verlauf")
        } footer: {
          Text("Ergebnisse deiner ausgewerteten Prüfungssimulationen. Das ist der ehrlichste Indikator, weil er die echte Prüfungssituation abbildet. Empfehlung: alle zwei Wochen eine Probeprüfung.")
        }

        Section {
          NavigationLink(value: TaskListRoute.topicDetails(track)) {
            Label("Alle Themen im Detail", systemImage: "list.bullet")
          }
        }
      }
      .themedBackground()
      .navigationTitle("Fortschritt")
      .examTaskDestinations()
    }
  }

  // MARK: - Gesamtfortschritt

  private func overallProgress(tasks: [ExamTask], summary: ProgressSummary) -> some View {
    let done = tasks.filter { summary.latestByTask[$0.id] != nil }.count
    let share = tasks.isEmpty ? 0 : Double(done) / Double(tasks.count)
    let graded = summary.latestByTask.values
    let correct = graded.map(\.score).reduce(0, +)
    let rate = (correct + 1) / (Double(graded.count) + 2)

    return VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .firstTextBaseline) {
        Text(share, format: .percent.precision(.fractionLength(0)))
          .font(.system(size: 44, weight: .bold, design: .rounded))
          .monospacedDigit()
        Text("aller Aufgaben bearbeitet")
          .foregroundStyle(.secondary)
      }
      ProgressView(value: share)
      ForEach(Subject.allCases) { subject in
        let subjectTasks = tasks.filter { $0.subject == subject }
        let subjectDone = subjectTasks.filter { summary.latestByTask[$0.id] != nil }.count
        LabeledContent {
          Text("\(subjectDone) von \(subjectTasks.count)")
            .monospacedDigit()
        } label: {
          Label(subject.title, systemImage: subject.systemImage)
        }
        .font(.subheadline)
      }
      if !graded.isEmpty {
        LabeledContent("Geschätzte Trefferquote") {
          Text(rate, format: .percent.precision(.fractionLength(0)))
            .monospacedDigit()
        }
        .font(.subheadline)
      }
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
  }

  // MARK: - Als Nächstes üben

  @ViewBuilder
  private func nextAreaRow(_ area: AreaProgress, task: ExamTask?) -> some View {
    let content = VStack(alignment: .leading, spacing: 6) {
      Label("Als Nächstes üben", systemImage: "arrow.forward.circle")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
      Text(area.area.title)
        .font(.headline)
      Text(area.stage == .neu ? "Diesen Bereich hast du noch nicht geübt." : "Hier kannst du am meisten dazugewinnen.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      if let task {
        Text("Los geht’s mit \(task.displayTitle) · \(String(task.year))")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.tint)
      }
    }
    .padding(.vertical, 4)

    if let task {
      NavigationLink(value: task) { content }
    } else {
      content
    }
  }

  // MARK: - Probeprüfungen

  @ViewBuilder
  private var examHistory: some View {
    let graded = sessions.filter { $0.track == track && $0.state == .graded }
    let points = graded.compactMap { session in
      session.result(from: attempts).map {
        ExamResultPoint(id: session.id, date: session.startDate, subject: session.subject, share: $0)
      }
    }
    if points.isEmpty {
      VStack(alignment: .leading, spacing: 8) {
        Text("Noch keine Probeprüfung ausgewertet.")
          .font(.subheadline)
        Text("Schreib unter «Prüfung» eine frühere Prüfung mit Originalzeit. Danach erscheint hier dein Ergebnis.")
          .font(.footnote)
          .foregroundStyle(.secondary)
        Button("Zur Prüfungssimulation") { selectedTab = .exam }
      }
      .padding(.vertical, 4)
    } else {
      ExamHistoryChart(points: points, target: examTarget)
        .padding(.vertical, 8)
      if let last = points.map(\.date).max() {
        let due = last.addingTimeInterval(examInterval)
        if due <= .now {
          Button {
            selectedTab = .exam
          } label: {
            Label("Zeit für die nächste Probeprüfung", systemImage: "timer")
          }
        } else {
          Label("Nächste Probeprüfung ab \(due.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar")
            .font(.subheadline)
        }
      }
      DisclosureGroup("Werte anzeigen") {
        ForEach(points.sorted { $0.date > $1.date }) { point in
          LabeledContent("\(point.subject.title), \(point.date.formatted(date: .abbreviated, time: .omitted))") {
            Text(point.share, format: .percent.precision(.fractionLength(0)))
              .monospacedDigit()
          }
          .font(.subheadline)
        }
      }
    }
  }
}
