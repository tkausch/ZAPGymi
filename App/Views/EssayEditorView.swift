import SwiftData
import SwiftUI

struct EssayEditorView: View {
  var task: ExamTask
  @Bindable var draft: EssayDraft
  @Environment(\.dismiss) private var dismiss
  @State private var confirmsShortText = false
  @FocusState private var isEditorFocused: Bool

  /// Assumption: below 150 words an essay is usually unfinished.
  private let minimumWords = 150

  private var duration: Double {
    Double(task.track.minutes(for: .aufsatz) * 60)
  }

  var body: some View {
    VStack(spacing: 0) {
      TimelineView(.periodic(from: .now, by: 1)) { context in
        timerBar(now: context.date)
      }
      if draft.writesOnPaper {
        ContentUnavailableView {
          Label("Schreib auf Papier", systemImage: "doc.text")
        } description: {
          Text("Wähle dein Thema, plane kurz und schreib deinen Text. Tippe auf «Fertig», wenn du abgibst.")
        }
      } else {
        TextEditor(text: $draft.text)
          .focused($isEditorFocused)
          .padding(.horizontal, 12)
          .onChange(of: draft.text) {
            draft.updatedAt = .now
          }
      }
    }
    .navigationTitle(task.displayTitle)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Fertig") {
          if !draft.writesOnPaper && draft.wordCount < minimumWords {
            confirmsShortText = true
          } else {
            finish()
          }
        }
      }
    }
    .alert("Dein Text ist noch kurz", isPresented: $confirmsShortText) {
      Button("Trotzdem abschliessen", action: finish)
      Button("Weiterschreiben", role: .cancel) {}
    } message: {
      Text("Er hat erst \(draft.wordCount) Wörter. An der Prüfung wird ein vollständiger Text mit Einleitung, Hauptteil und Schluss erwartet.")
    }
    .onAppear {
      if !draft.writesOnPaper { isEditorFocused = true }
    }
  }

  private func timerBar(now: Date) -> some View {
    let remaining = draft.startedAt.addingTimeInterval(duration).timeIntervalSince(now)
    return HStack {
      Label {
        if remaining >= 0 {
          Text("Noch \(TimeFormatting.clock(remaining))")
            .monospacedDigit()
        } else {
          Text("Zeit um · \(TimeFormatting.clock(-remaining)) überzogen")
            .monospacedDigit()
        }
      } icon: {
        Image(systemName: remaining >= 0 ? "timer" : "exclamationmark.triangle")
      }
      .foregroundStyle(remaining >= 0 ? AnyShapeStyle(.primary) : AnyShapeStyle(.orange))
      Spacer()
      if !draft.writesOnPaper {
        Text("\(draft.wordCount) Wörter")
          .monospacedDigit()
          .foregroundStyle(.secondary)
      }
    }
    .font(.subheadline)
    .padding(.horizontal)
    .padding(.vertical, 10)
    .background(.bar)
    .accessibilityElement(children: .combine)
  }

  private func finish() {
    draft.finishedAt = .now
    dismiss()
  }
}
