import SwiftData
import SwiftUI

struct EssayDetailView: View {
  var task: ExamTask
  @Environment(\.modelContext) private var modelContext
  @Query private var drafts: [EssayDraft]
  @State private var openedDraft: EssayDraft?
  @State private var assessedDraft: EssayDraft?
  @State private var shownDocument: ExamDocumentKind?

  init(task: ExamTask) {
    self.task = task
    let id = task.id
    _drafts = Query(filter: #Predicate<EssayDraft> { $0.taskID == id }, sort: \EssayDraft.startedAt, order: .reverse)
  }

  private var currentDraft: EssayDraft? {
    drafts.first { $0.assessedAt == nil }
  }

  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text(task.displayTitle)
            .font(.title2.bold())
          Text("\(task.track.title) \(String(task.year)) · Thema \(task.number)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        Text(task.text)
          .font(.body)
        if task.needsOwnTitle {
          Label("Für dieses Thema setzt du selbst einen Titel.", systemImage: "textformat")
            .font(.subheadline)
        }
      }

      Section("An der Prüfung") {
        Label("\(task.track.minutes(for: .aufsatz)) Minuten", systemImage: "clock")
        Text(task.track.allowedAids(for: .aufsatz))
          .font(.subheadline)
        if PDFLibrary.url(year: task.year, track: task.track, subject: .aufsatz, kind: .aufgaben) != nil {
          Button {
            shownDocument = .aufgaben
          } label: {
            Label("Themenblatt mit Bildern und Material", systemImage: "doc.richtext")
          }
        } else {
          Text("Das Themenblatt dieses Jahrgangs fehlt noch. Bezieht sich das Thema auf ein Bild oder einen Text, kannst du es erst üben, wenn das Material da ist.")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        if PDFLibrary.url(year: task.year, track: task.track, subject: .aufsatz, kind: .korrektur) != nil {
          Button {
            shownDocument = .korrektur
          } label: {
            Label("Offizielle Korrekturhinweise", systemImage: "checklist")
          }
        }
      }

      Section("Schreiben") {
        if let draft = currentDraft {
          if draft.finishedAt == nil {
            Button {
              openedDraft = draft
            } label: {
              Label(draft.writesOnPaper ? "Zum Timer" : "Weiterschreiben (\(draft.wordCount) Wörter)", systemImage: "pencil.line")
            }
          } else {
            Button {
              assessedDraft = draft
            } label: {
              Label("Jetzt einschätzen", systemImage: "checklist")
            }
          }
        } else {
          Button {
            start(onPaper: false)
          } label: {
            Label("In der App schreiben", systemImage: "keyboard")
          }
          Button {
            start(onPaper: true)
          } label: {
            Label("Auf Papier schreiben, mit Timer", systemImage: "doc.text")
          }
        }
      }

      let assessed = drafts.filter { $0.assessedAt != nil }
      if !assessed.isEmpty {
        Section("Frühere Aufsätze") {
          ForEach(assessed) { draft in
            Button {
              assessedDraft = draft
            } label: {
              LabeledContent(draft.startedAt.formatted(date: .abbreviated, time: .omitted)) {
                Text("\(draft.checkedItems.count) von \(EssayChecklist.items(for: task).count) Punkten erfüllt")
              }
            }
            .tint(.primary)
          }
        }
      }
    }
    .themedBackground()
    .navigationTitle("Aufsatz")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        SaveTaskButton(task: task)
      }
    }
    .navigationDestination(item: $openedDraft) { draft in
      EssayEditorView(task: task, draft: draft)
    }
    .sheet(item: $assessedDraft) { draft in
      EssayChecklistView(task: task, draft: draft)
    }
    .sheet(item: $shownDocument) { kind in
      DocumentSheet(task: task, kind: kind, title: kind == .aufgaben ? "Themenblatt" : kind.title)
    }
  }

  private func start(onPaper: Bool) {
    let draft = EssayDraft(taskID: task.id, writesOnPaper: onPaper)
    modelContext.insert(draft)
    openedDraft = draft
  }
}
