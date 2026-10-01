import Foundation

/// A short piece of advice on how to prepare for the exam.
struct LearningTip: Identifiable {
  var title: String
  var text: String
  var systemImage: String

  var id: String { title }

  static func tips(for track: ExamTrack) -> [LearningTip] {
    switch track {
    case .langzeit:
      [
        LearningTip(
          title: "Alte Prüfungen nicht zu früh lösen",
          text: "Löse die alten Prüfungen in dieser App nicht zu früh. Sonst wirst du sehr wahrscheinlich frustriert sein: Die Prüfungen verlangen den Stoff der 6. Klasse, und den lernst du erst im Laufe des Schuljahres. Dass du sie vorher lösen kannst, ist fast unmöglich, und das ist ganz normal.",
          systemImage: "hourglass"
        ),
        LearningTip(
          title: "Früh anfangen, kurz üben",
          text: "Starte 4 bis 6 Monate vor der Prüfung. 3 bis 5 Stunden pro Woche reichen, aufgeteilt in Häppchen von 10 bis 15 Minuten.",
          systemImage: "calendar"
        ),
        LearningTip(
          title: "Die wichtigsten Themen zuerst",
          text: "Übe zuerst Brüche, Prozent, Grössen und Textaufgaben. Dazu gehört das Konstruieren von Dreiecken mit Zirkel und Geodreieck.",
          systemImage: "list.number"
        ),
        LearningTip(
          title: "Alte Prüfungen mit Zeitdruck",
          text: "Löse frühere Prüfungen mit der echten Zeit. In Mathematik hast du 60 Minuten.",
          systemImage: "timer"
        ),
        LearningTip(
          title: "Im Text suchen statt raten",
          text: "Beim Textverständnis steht die Antwort meistens im Text. Such die passende Stelle und lies sie genau.",
          systemImage: "text.magnifyingglass"
        ),
      ]
    case .kurzzeit:
      [
        LearningTip(
          title: "Eigener Wochenplan",
          text: "Du übst selbständig. Plane deine Woche mit festen Übungszeiten und halte dich daran.",
          systemImage: "calendar.badge.clock"
        ),
        LearningTip(
          title: "Algebra kommt dazu",
          text: "Neben Brüchen, Prozent und Geometrie brauchst du Algebra: Terme, Gleichungen und binomische Formeln.",
          systemImage: "x.squareroot"
        ),
        LearningTip(
          title: "Lösungsweg sauber aufschreiben",
          text: "Schreib jeden Schritt nachvollziehbar auf. Nur so bekommst du Teilpunkte, auch wenn das Resultat nicht stimmt.",
          systemImage: "checklist"
        ),
        LearningTip(
          title: "Langer Prüfungstag, bewusste Pausen",
          text: "Mathematik dauert 90 Minuten, und der ganze Prüfungstag ist lang. Nutze die Pausen, um dich zu erholen.",
          systemImage: "cup.and.saucer"
        ),
        LearningTip(
          title: "Probeprüfungen unter echten Bedingungen",
          text: "Schreib mindestens 2 bis 3 Probeprüfungen mit Originalzeit und ohne Hilfen.",
          systemImage: "timer"
        ),
      ]
    }
  }

  /// Tips for both exam types.
  static let general: [LearningTip] = [
    LearningTip(
      title: "Verstehen statt auswendig lernen",
      text: "Frag dich bei jeder Lösung, warum sie funktioniert. Was du verstanden hast, kannst du auch bei neuen Aufgaben anwenden.",
      systemImage: "lightbulb"
    ),
    LearningTip(
      title: "Mehrere Probeprüfungen",
      text: "Löse mehrere Prüfungen aus früheren Jahren. So siehst du, wo du stehst und welche Aufgaben dir noch Mühe machen. Ähnliche Aufgabentypen kommen immer wieder vor: Wer sie kennt, ist an der Prüfung im Vorteil.",
      systemImage: "doc.on.doc"
    ),
  ]
}
