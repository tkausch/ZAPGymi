import Foundation

extension Outcome {
  /// Encouraging feedback, in simpler language for younger children.
  func feedback(for track: ExamTrack) -> String {
    switch (self, track.usesSimpleLanguage) {
    case (.richtig, true): "Super gemacht! Diese Aufgabe kannst du."
    case (.richtig, false): "Volle Punktzahl."
    case (.teilweise, true): "Gut, ein Teil stimmt schon. In drei Tagen übst du die Aufgabe nochmals."
    case (.teilweise, false): "Teilpunkte. Die Aufgabe kommt in drei Tagen zur Wiederholung."
    case (.falsch, true): "Nicht schlimm, aus Fehlern lernst du am meisten. Schau dir die Lösung genau an. In drei Tagen übst du die Aufgabe nochmals."
    case (.falsch, false): "Noch nicht gelöst. Die Aufgabe kommt in drei Tagen zur Wiederholung."
    }
  }
}
