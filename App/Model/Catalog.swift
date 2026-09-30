import Foundation

/// All past exam tasks bundled with the app.
struct Catalog {
  var tasks: [ExamTask]

  static let empty = Catalog(tasks: [])

  static func load(bundle: Bundle = .main) -> Catalog {
    var tasks: [ExamTask] = []
    tasks += decode([MathTaskRecord].self, named: "mathtasks", bundle: bundle)?.compactMap(\.task) ?? []
    tasks += decode([LanguageTaskRecord].self, named: "sprachpruefung", bundle: bundle)?.compactMap(\.task) ?? []
    tasks += decode([EssayRecord].self, named: "aufsatz", bundle: bundle)?.compactMap(\.task) ?? []
    return Catalog(tasks: tasks)
  }

  func tasks(for track: ExamTrack, subject: Subject? = nil) -> [ExamTask] {
    tasks.filter { $0.track == track && (subject == nil || $0.subject == subject) }
  }

  func tasks(for track: ExamTrack, subject: Subject, year: Int) -> [ExamTask] {
    tasks(for: track, subject: subject)
      .filter { $0.year == year }
      .sorted { $0.sortKey < $1.sortKey }
  }

  func years(for track: ExamTrack, subject: Subject) -> [Int] {
    Set(tasks(for: track, subject: subject).map(\.year)).sorted(by: >)
  }

  func topics(for track: ExamTrack, subject: Subject) -> [String] {
    Set(tasks(for: track, subject: subject).map(\.topic)).sorted()
  }

  func task(id: String) -> ExamTask? {
    tasks.first { $0.id == id }
  }

  private static func decode<T: Decodable>(_ type: T.Type, named name: String, bundle: Bundle) -> T? {
    guard let url = bundle.url(forResource: name, withExtension: "json"),
          let data = try? Data(contentsOf: url) else { return nil }
    return try? JSONDecoder().decode(type, from: data)
  }

  /// Merges math categories that mean the same thing.
  fileprivate static func normalizedMathCategory(_ category: String) -> String {
    let merged: [String: String] = [
      "Geometrie: Konstruktion": "Konstruktion",
      "Zahlenfolgen und Muster": "Zahlenfolgen",
      "Geometrie: Flaeche und Umfang": "Fläche und Umfang",
      "Flächenberechnung": "Fläche und Umfang",
      "Geometrie: Volumen und Oberflaeche": "Volumen und Oberfläche",
      "Volumenberechnung": "Volumen und Oberfläche",
      "Geometrie: Symmetrie": "Symmetrie",
    ]
    return merged[category] ?? category.restoringUmlauts
  }
}

private struct MathTaskRecord: Decodable {
  var year: Int?
  var taskNumber: String?
  var track: String?
  var key: String?
  var description: String?
  var topic: String?
  var category: String?
  var difficulty: String?
  var points: Int?

  var task: ExamTask? {
    guard let year, let taskNumber, let track = track.flatMap(ExamTrack.init(rawValue:)),
          let key, let description, let category else { return nil }
    return ExamTask(
      id: key,
      year: year,
      number: taskNumber,
      track: track,
      subject: .mathematik,
      title: nil,
      text: description.restoringUmlauts,
      topic: Catalog.normalizedMathCategory(category),
      topicDetail: topic?.restoringUmlauts,
      difficulty: difficulty.flatMap(Difficulty.init(dataValue:)),
      maxPoints: points
    )
  }
}

private struct LanguageTaskRecord: Decodable {
  var jahr: Int?
  var nummer: Int?
  var punktzahl: Int?
  var track: String?
  var thema: String?
  var beschreibung: String?

  var task: ExamTask? {
    guard let jahr, let nummer, let track = track.flatMap(ExamTrack.init(rawValue:)),
          let beschreibung else { return nil }
    return ExamTask(
      id: "\(jahr)-\(track.rawValue)-S\(nummer)",
      year: jahr,
      number: String(nummer),
      track: track,
      subject: .sprache,
      title: nil,
      text: beschreibung,
      topic: thema ?? "Weitere",
      topicDetail: nil,
      difficulty: nil,
      maxPoints: punktzahl
    )
  }
}

private struct EssayRecord: Decodable {
  var jahr: Int?
  var nummer: Int?
  var track: String?
  var title: String?
  var beschreibung: String?

  var task: ExamTask? {
    guard let jahr, let nummer, let track = track.flatMap(ExamTrack.init(rawValue:)),
          let beschreibung else { return nil }
    return ExamTask(
      id: "\(jahr)-\(track.rawValue)-A\(nummer)",
      year: jahr,
      number: String(nummer),
      track: track,
      subject: .aufsatz,
      title: title,
      text: beschreibung,
      topic: "Aufsatz",
      topicDetail: nil,
      difficulty: nil,
      maxPoints: nil
    )
  }
}
