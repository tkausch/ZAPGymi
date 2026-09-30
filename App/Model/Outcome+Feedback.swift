import Foundation

extension Outcome {
  /// Encouraging feedback, in simpler language for younger children.
  func feedback(for track: ExamTrack) -> String {
    switch (self, track.usesSimpleLanguage) {
    case (.richtig, true): "Super gemacht! Diese Aufgabe kannst du."
    case (.richtig, false): "Volle Punktzahl."
    case (.teilweise, true): "Gut, ein Teil stimmt schon. Die Aufgabe steht jetzt unter «Zu wiederholen»."
    case (.teilweise, false): "Teilpunkte. Die Aufgabe steht jetzt unter «Zu wiederholen»."
    case (.falsch, true): "Nicht schlimm, aus Fehlern lernst du am meisten. Schau dir die Lösung genau an. Die Aufgabe steht jetzt unter «Zu wiederholen»."
    case (.falsch, false): "Noch nicht gelöst. Die Aufgabe steht jetzt unter «Zu wiederholen»."
    }
  }
}
