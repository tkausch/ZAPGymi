import SwiftData
import SwiftUI

struct EssayChecklistView: View {
  var task: ExamTask
  @Bindable var draft: EssayDraft
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    let items = EssayChecklist.items(for: task)
    NavigationStack {
      List {
        Section {
          ForEach(items.indices, id: \.self) { index in
            Button {
              toggle(index)
            } label: {
              Label {
                Text(items[index])
                  .foregroundStyle(.primary)
              } icon: {
                Image(systemName: draft.checkedItems.contains(index) ? "checkmark.circle.fill" : "circle")
                  .foregroundStyle(draft.checkedItems.contains(index) ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
              }
            }
            .tint(.primary)
            .accessibilityAddTraits(draft.checkedItems.contains(index) ? .isSelected : [])
          }
        } header: {
          Text("Hast du das erfüllt?")
        } footer: {
          Text(task.track.usesSimpleLanguage
            ? "Lies deinen Text nochmals durch und hake ab, was stimmt. Du kannst die Liste auch mit deinen Eltern durchgehen."
            : "Prüfe deinen Text Punkt für Punkt gegen die Aufgabenstellung, allein oder mit jemandem, der ihn liest.")
        }

        if !draft.writesOnPaper && !draft.text.isEmpty {
          Section("Dein Text (\(draft.wordCount) Wörter)") {
            Text(draft.text)
              .font(.callout)
          }
        }
      }
      .navigationTitle("Einschätzen")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Später") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Speichern") { save(itemCount: items.count) }
        }
      }
    }
  }

  private func toggle(_ index: Int) {
    if let position = draft.checkedItems.firstIndex(of: index) {
      draft.checkedItems.remove(at: position)
    } else {
      draft.checkedItems.append(index)
    }
  }

  private func save(itemCount: Int) {
    let isFirstAssessment = draft.assessedAt == nil
    draft.assessedAt = .now
    if isFirstAssessment {
      let share = itemCount == 0 ? 0 : Double(draft.checkedItems.count) / Double(itemCount)
      let outcome: Outcome = share >= 0.8 ? .richtig : (share >= 0.4 ? .teilweise : .falsch)
      modelContext.insert(Attempt(taskID: task.id, points: nil, maxPoints: nil, outcome: outcome))
    }
    dismiss()
  }
}
