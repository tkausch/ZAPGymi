import Foundation

/// A broad exam area for the topic map, grouping the detailed topics of the task data.
enum LearningArea: String, CaseIterable, Identifiable, Hashable {
  case zahlen
  case algebra
  case textaufgaben
  case geometrie
  case kombinatorik
  case textverstaendnis
  case grammatik
  case wortschatz
  case zeichensetzung
  case aufsatz

  var id: String { rawValue }

  var title: String {
    switch self {
    case .zahlen: "Zahlen und Rechnen"
    case .algebra: "Algebra und Gleichungen"
    case .textaufgaben: "Textaufgaben"
    case .geometrie: "Geometrie"
    case .kombinatorik: "Kombinatorik und Wahrscheinlichkeit"
    case .textverstaendnis: "Textverständnis"
    case .grammatik: "Grammatik"
    case .wortschatz: "Wortschatz"
    case .zeichensetzung: "Zeichensetzung"
    case .aufsatz: "Aufsatz"
    }
  }

  var systemImage: String {
    switch self {
    case .zahlen: "number"
    case .algebra: "x.squareroot"
    case .textaufgaben: "text.page"
    case .geometrie: "triangle"
    case .kombinatorik: "dice"
    case .textverstaendnis: "text.magnifyingglass"
    case .grammatik: "textformat.abc"
    case .wortschatz: "character.book.closed"
    case .zeichensetzung: "ellipsis.curlybraces"
    case .aufsatz: "pencil.line"
    }
  }

  var subject: Subject {
    switch self {
    case .zahlen, .algebra, .textaufgaben, .geometrie, .kombinatorik: .mathematik
    case .textverstaendnis, .grammatik, .wortschatz, .zeichensetzung: .sprache
    case .aufsatz: .aufsatz
    }
  }

  /// The area a task belongs to, based on its topic.
  static func area(for task: ExamTask) -> LearningArea {
    switch task.subject {
    case .aufsatz:
      return .aufsatz
    case .sprache:
      switch task.topic {
      case "Textverständnis": return .textverstaendnis
      case "Wortbildung", "Synonyme/Antonyme", "Redewendungen", "Wortfeld": return .wortschatz
      case "Zeichensetzung": return .zeichensetzung
      default: return .grammatik
      }
    case .mathematik:
      switch task.topic {
      case "Termumformung", "Gleichungen", "Verhältnisse und Gleichungen", "Funktionen/Diagramme", "Zahlenfolgen":
        return .algebra
      case "Sachaufgabe/Modellierung", "Sachrechnen mehrstufig", "Rückwärtsrechnen", "Geschwindigkeit, Zeit und Strecke",
           "Proportionalität", "Optimierung":
        return .textaufgaben
      case "Fläche und Umfang", "Volumen und Oberfläche", "Konstruktion", "Symmetrie", "Koordinatensystem",
           "Raumvorstellung (3D-Geometrie)":
        return .geometrie
      case "Kombinatorik und systematisches Probieren", "Wahrscheinlichkeit":
        return .kombinatorik
      default:
        return .zahlen
      }
    }
  }
}

/// How far the child is in an area.
enum MasteryStage: CaseIterable {
  case neu
  case angefangen
  case uebenNoetig
  case sicher
  case gemeistert

  var title: String {
    switch self {
    case .neu: "Neu"
    case .angefangen: "Angefangen"
    case .uebenNoetig: "Üben nötig"
    case .sicher: "Sicher"
    case .gemeistert: "Gemeistert"
    }
  }

  var systemImage: String {
    switch self {
    case .neu: "circle.dashed"
    case .angefangen: "circle.lefthalf.filled"
    case .uebenNoetig: "exclamationmark.triangle"
    case .sicher: "checkmark"
    case .gemeistert: "star.fill"
    }
  }

  /// Order for «Als Nächstes üben»: real gaps first, then untouched and started areas.
  var recommendationPriority: Int {
    switch self {
    case .uebenNoetig: 0
    case .neu: 1
    case .angefangen: 2
    case .sicher: 3
    case .gemeistert: 4
    }
  }

  /// Assumptions, with the smoothed score (correct + 1) / (attempted + 2):
  /// fewer than 5 tasks = Angefangen; from 5 tasks below 60 % = Üben nötig, from 60 % = Sicher;
  /// from 10 tasks and 80 % = Gemeistert.
  static func stage(attempted: Int, score: Double) -> MasteryStage {
    if attempted == 0 { return .neu }
    if attempted < 5 { return .angefangen }
    if attempted >= 10 && score >= 0.8 { return .gemeistert }
    return score >= 0.6 ? .sicher : .uebenNoetig
  }
}

struct AreaProgress: Identifiable {
  var area: LearningArea
  var attempted: Int
  var total: Int
  var score: Double
  var stage: MasteryStage

  var id: LearningArea { area }
}

extension ProgressSummary {
  /// Progress per area, in the fixed order of the areas. Areas without tasks are left out.
  func areaProgress(for tasks: [ExamTask]) -> [AreaProgress] {
    let grouped = Dictionary(grouping: tasks, by: LearningArea.area(for:))
    return LearningArea.allCases.compactMap { area in
      guard let areaTasks = grouped[area], !areaTasks.isEmpty else { return nil }
      let graded = areaTasks.compactMap { latestByTask[$0.id] }
      let correct = graded.map(\.score).reduce(0, +)
      let score = (correct + 1) / (Double(graded.count) + 2)
      return AreaProgress(
        area: area,
        attempted: graded.count,
        total: areaTasks.count,
        score: score,
        stage: MasteryStage.stage(attempted: graded.count, score: score)
      )
    }
  }

  /// The area to practise next: «Üben nötig» first, then new, started and secure areas; within a stage
  /// the weakest area, or for new areas the one with the most exam tasks.
  func nextArea(from progress: [AreaProgress]) -> AreaProgress? {
    progress
      .filter { $0.stage != .gemeistert && $0.attempted < $0.total }
      .min { lhs, rhs in
        if lhs.stage != rhs.stage { return lhs.stage.recommendationPriority < rhs.stage.recommendationPriority }
        if lhs.stage == .neu { return lhs.total > rhs.total }
        return lhs.score < rhs.score
      }
  }

  /// A concrete open task in an area: least practised topic first, then easier and newer tasks.
  func nextTask(in area: LearningArea, from tasks: [ExamTask]) -> ExamTask? {
    let areaTasks = tasks.filter { LearningArea.area(for: $0) == area }
    let practiceCount = Dictionary(grouping: areaTasks.filter { latestByTask[$0.id] != nil }, by: \.topic).mapValues(\.count)
    return areaTasks
      .filter { latestByTask[$0.id] == nil && $0.isAvailable }
      .min { lhs, rhs in
        let lhsCount = practiceCount[lhs.topic] ?? 0
        let rhsCount = practiceCount[rhs.topic] ?? 0
        if lhsCount != rhsCount { return lhsCount < rhsCount }
        let lhsDifficulty = lhs.difficulty ?? .mittel
        let rhsDifficulty = rhs.difficulty ?? .mittel
        if lhsDifficulty != rhsDifficulty { return lhsDifficulty < rhsDifficulty }
        return lhs.year != rhs.year ? lhs.year > rhs.year : lhs.sortKey < rhs.sortKey
      }
  }
}
