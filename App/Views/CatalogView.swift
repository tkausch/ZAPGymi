import SwiftData
import SwiftUI

struct TaskFilter: Equatable {
  var year: Int?
  var topic: String?
  var difficulty: Difficulty?
  var onlyOpen = false
  var onlySaved = false

  var isActive: Bool { self != TaskFilter() }

  var summary: String {
    var parts: [String] = []
    if let year { parts.append(String(year)) }
    if let topic { parts.append(topic) }
    if let difficulty { parts.append(difficulty.title) }
    if onlyOpen { parts.append("nur ungelöste") }
    if onlySaved { parts.append("nur gemerkte") }
    return parts.joined(separator: " · ")
  }
}

struct CatalogView: View {
  var track: ExamTrack
  @Environment(\.catalog) private var catalog
  @Environment(\.modelContext) private var modelContext
  @Query private var attempts: [Attempt]
  @Query private var saved: [SavedTask]
  @State private var subject = Subject.mathematik
  @State private var filter = TaskFilter()
  @State private var searchText = ""

  var body: some View {
    let summary = ProgressSummary(attempts: attempts)
    let savedIDs = Set(saved.map(\.taskID))
    let unfiltered = matching(filter: TaskFilter(year: filter.year, topic: filter.topic, difficulty: filter.difficulty, onlySaved: filter.onlySaved), summary: summary, savedIDs: savedIDs)
    let tasks = matching(filter: filter, summary: summary, savedIDs: savedIDs)
    let years = Set(tasks.map(\.year)).sorted(by: >)

    NavigationStack {
      List {
        Section {
          Picker("Fach", selection: $subject) {
            ForEach(Subject.allCases) { subject in
              Text(subject.title).tag(subject)
            }
          }
          .pickerStyle(.segmented)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets())
        }

        if filter.isActive {
          Section {
            HStack {
              Label(filter.summary, systemImage: "line.3.horizontal.decrease")
                .font(.subheadline)
              Spacer()
              Button("Zurücksetzen") { filter = TaskFilter() }
                .font(.subheadline)
            }
          }
        }

        ForEach(years, id: \.self) { year in
          Section(String(year)) {
            ForEach(tasks.filter { $0.year == year }) { task in
              NavigationLink(value: task) {
                TaskRow(task: task, status: summary.status(of: task), showsYear: false, isSaved: savedIDs.contains(task.id))
              }
              .saveSwipeAction(for: task, isSaved: savedIDs.contains(task.id), in: modelContext)
            }
          }
        }
      }
      .overlay {
        if tasks.isEmpty {
          emptyState(allSolved: filter.onlyOpen && !unfiltered.isEmpty)
        }
      }
      .themedBackground()
      .navigationTitle("Aufgaben")
      .searchable(text: $searchText, prompt: "Aufgaben durchsuchen")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          filterMenu
        }
      }
      .onChange(of: subject) {
        filter.topic = nil
        filter.difficulty = nil
      }
      .examTaskDestinations()
    }
  }

  private var filterMenu: some View {
    Menu {
      Picker("Jahr", selection: $filter.year) {
        Text("Alle Jahre").tag(Int?.none)
        ForEach(catalog.years(for: track, subject: subject), id: \.self) { year in
          Text(String(year)).tag(Optional(year))
        }
      }
      .pickerStyle(.menu)

      if subject != .aufsatz {
        Picker("Thema", selection: $filter.topic) {
          Text("Alle Themen").tag(String?.none)
          ForEach(catalog.topics(for: track, subject: subject), id: \.self) { topic in
            Text(topic).tag(Optional(topic))
          }
        }
        .pickerStyle(.menu)
      }

      if subject == .mathematik {
        Picker("Schwierigkeit", selection: $filter.difficulty) {
          Text("Alle Stufen").tag(Difficulty?.none)
          ForEach(Difficulty.allCases) { difficulty in
            Text(difficulty.title).tag(Optional(difficulty))
          }
        }
        .pickerStyle(.menu)
      }

      Toggle("Nur ungelöste", isOn: $filter.onlyOpen)
      Toggle("Nur gemerkte", isOn: $filter.onlySaved)

      if filter.isActive {
        Button("Filter zurücksetzen", role: .destructive) {
          filter = TaskFilter()
        }
      }
    } label: {
      Label("Filter", systemImage: "line.3.horizontal.decrease")
    }
  }

  @ViewBuilder
  private func emptyState(allSolved: Bool) -> some View {
    if allSolved {
      ContentUnavailableView {
        Label("Alles gelöst!", systemImage: "checkmark.seal")
      } description: {
        Text("Du hast alle Aufgaben mit diesem Filter bearbeitet. Du kannst sie wiederholen.")
      } actions: {
        Button("Gelöste Aufgaben zeigen") { filter.onlyOpen = false }
      }
    } else if filter.onlySaved && saved.isEmpty {
      ContentUnavailableView {
        Label("Noch nichts gemerkt", systemImage: "bookmark")
      } description: {
        Text("Tippe in einer Aufgabe auf das Lesezeichen oder wische in der Liste nach rechts, um dir eine Aufgabe zu merken.")
      } actions: {
        Button("Alle Aufgaben zeigen") { filter.onlySaved = false }
      }
    } else if !searchText.isEmpty && !filter.isActive {
      ContentUnavailableView.search(text: searchText)
    } else {
      ContentUnavailableView {
        Label("Keine passenden Aufgaben", systemImage: "line.3.horizontal.decrease")
      } description: {
        Text("Zu diesen Filtern gibt es keine Aufgaben.")
      } actions: {
        Button("Filter zurücksetzen") {
          filter = TaskFilter()
          searchText = ""
        }
      }
    }
  }

  private func matching(filter: TaskFilter, summary: ProgressSummary, savedIDs: Set<String>) -> [ExamTask] {
    let query = searchText.trimmingCharacters(in: .whitespaces)
    return catalog.tasks(for: track, subject: subject)
      .filter { task in
        (filter.year == nil || task.year == filter.year)
          && (filter.topic == nil || task.topic == filter.topic)
          && (filter.difficulty == nil || task.difficulty == filter.difficulty)
          && (!filter.onlyOpen || summary.status(of: task).outcome == nil)
          && (!filter.onlySaved || savedIDs.contains(task.id))
          && (query.isEmpty
            || task.text.localizedStandardContains(query)
            || task.topic.localizedStandardContains(query)
            || (task.title ?? "").localizedStandardContains(query))
      }
      .sorted { lhs, rhs in
        lhs.year != rhs.year ? lhs.year > rhs.year : lhs.sortKey < rhs.sortKey
      }
  }
}
