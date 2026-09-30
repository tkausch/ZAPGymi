import Foundation

enum ExamTrack: String, CaseIterable, Identifiable, Codable {
  case langzeit = "Langgymnasium"
  case kurzzeit = "Kurzgymnasium"

  var id: String { rawValue }

  var title: String {
    switch self {
    case .langzeit: "Langzeitgymnasium"
    case .kurzzeit: "Kurzzeitgymnasium"
    }
  }

  var shortTitle: String {
    switch self {
    case .langzeit: "Langzeit"
    case .kurzzeit: "Kurzzeit"
    }
  }

  var audience: String {
    switch self {
    case .langzeit: "Übertritt nach der 6. Klasse der Primarschule"
    case .kurzzeit: "Übertritt aus der 2. oder 3. Sekundarschule"
    }
  }

  /// Short code used in the bundled PDF file names.
  var fileCode: String {
    switch self {
    case .langzeit: "lg"
    case .kurzzeit: "kg"
    }
  }

  /// Younger children get simpler, more encouraging wording.
  var usesSimpleLanguage: Bool { self == .langzeit }

  /// Original exam time in minutes, taken from the cover pages of the exams.
  func minutes(for subject: Subject) -> Int {
    switch (self, subject) {
    case (.langzeit, .mathematik): 60
    case (.kurzzeit, .mathematik): 90
    case (_, .sprache): 45
    case (.langzeit, .aufsatz): 60
    case (.kurzzeit, .aufsatz): 90
    }
  }

  /// Aids allowed at the exam, taken from the cover pages of the exams.
  func allowedAids(for subject: Subject) -> String {
    switch (self, subject) {
    case (.langzeit, .mathematik):
      "Ohne Taschenrechner. Schreib den Lösungsweg auf, sonst gibt es keine Punkte."
    case (.kurzzeit, .mathematik):
      "Einfacher Taschenrechner erlaubt. Lösungswege und Zwischenresultate müssen ersichtlich sein."
    case (.langzeit, .sprache):
      "Keine Hilfsmittel. Lies zuerst den Text auf dem Textblatt."
    case (.kurzzeit, .sprache):
      "Keine Hilfsmittel, auch kein Wörterbuch. Lies zuerst den Text auf dem Textblatt."
    case (.langzeit, .aufsatz):
      "Wähle eines der Themen. Schreib mit Füllfeder oder Kugelschreiber."
    case (.kurzzeit, .aufsatz):
      "Wähle eines der Themen. Ein Rechtschreibwörterbuch ist erlaubt."
    }
  }
}
