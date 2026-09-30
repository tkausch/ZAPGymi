import Foundation

/// Builds a self-assessment checklist from the wording of an essay topic.
enum EssayChecklist {
  static func items(for task: ExamTask) -> [String] {
    var items = taskSentences(in: task.text)
    let text = task.text

    if text.contains("Präteritum") {
      items.append("Durchgehend im Präteritum geschrieben")
    }
    if text.contains("nicht in der Ich-Form") {
      items.append("Nicht in der Ich-Form geschrieben")
    } else if text.contains("Ich-Form") || text.contains("1. Person Singular") {
      items.append("In der Ich-Form geschrieben")
    }
    if text.contains("Zeitung") {
      items.append("Sachlich wie ein Zeitungsbericht: wer, was, wann, wo, wie, warum")
    }
    if task.needsOwnTitle || text.contains("Titel") {
      items.append("Einen eigenen, treffenden Titel gesetzt")
    }
    if text.contains("Unterstreiche") {
      items.append("Die vorgegebenen Wörter unterstrichen")
    }
    items.append("Klarer Aufbau mit Einleitung, Hauptteil und Schluss")
    items.append("Rechtschreibung und Satzzeichen nochmals kontrolliert")
    return items
  }

  /// Sentences like "Verwende das Präteritum." are covered by the dedicated form items.
  private static func isFormRequirement(_ sentence: String) -> Bool {
    let markers = ["Präteritum", "Ich-Form", "Person Singular", "Titel"]
    return sentence.count < 90 && markers.contains { sentence.contains($0) }
  }

  /// Every instruction or question of the topic becomes one checklist item. Quoted story openings are skipped.
  private static func taskSentences(in text: String) -> [String] {
    var sentences: [String] = []
    var current = ""
    var quoteDepth = 0
    for character in text {
      current.append(character)
      if character == "«" { quoteDepth += 1 }
      if character == "»" { quoteDepth = max(0, quoteDepth - 1) }
      if quoteDepth == 0, ".?!".contains(character) {
        sentences.append(current)
        current = ""
      }
    }
    sentences.append(current)
    return sentences
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { sentence in
        !isFormRequirement(sentence) && sentence.count > 15 && !sentence.hasPrefix("«") && !sentence.hasPrefix("(") && !sentence.contains("…»") && !sentence.contains("...»")
      }
  }
}
