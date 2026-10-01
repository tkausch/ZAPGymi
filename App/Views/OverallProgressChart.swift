import Charts
import SwiftUI

/// Status of the tasks of one subject, for the progress pies.
enum TaskProgressSegment: String, CaseIterable, Identifiable {
  case richtig
  case teilweise
  case falsch
  case offen

  var id: String { rawValue }

  var title: String {
    switch self {
    case .richtig: "Richtig"
    case .teilweise: "Teilweise"
    case .falsch: "Falsch"
    case .offen: "Offen"
    }
  }

  /// Status colours (good, warning, critical) plus a neutral track for open tasks.
  /// Distinguishable with colour blindness; the legend always names them.
  var color: Color {
    switch self {
    case .richtig: Color(light: 0x0CA30C, dark: 0x0CA30C)
    case .teilweise: Color(light: 0xF5A623, dark: 0xFAB219)
    case .falsch: Color(light: 0xD03B3B, dark: 0xD03B3B)
    case .offen: Color.secondary.opacity(0.2)
    }
  }
}

struct SubjectProgress: Identifiable {
  var subject: Subject
  var counts: [TaskProgressSegment: Int]
  var total: Int

  var id: Subject { subject }
  var done: Int { total - (counts[.offen] ?? 0) }
  var share: Double { total > 0 ? Double(done) / Double(total) : 0 }
}

/// One donut per subject, split into correct, partial, wrong and open tasks, with a shared legend.
struct OverallProgressChart: View {
  var subjects: [SubjectProgress]

  private let columns = [GridItem(.adaptive(minimum: 96), spacing: 12)]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      LazyVGrid(columns: columns, spacing: 16) {
        ForEach(subjects) { progress in
          SubjectDonut(progress: progress)
        }
      }
      legend
    }
  }

  private var legend: some View {
    let totals = Dictionary(uniqueKeysWithValues: TaskProgressSegment.allCases.map { segment in
      (segment, subjects.map { $0.counts[segment] ?? 0 }.reduce(0, +))
    })
    return LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), alignment: .leading)], alignment: .leading, spacing: 6) {
      ForEach(TaskProgressSegment.allCases) { segment in
        HStack(spacing: 6) {
          RoundedRectangle(cornerRadius: 2)
            .fill(segment.color)
            .frame(width: 10, height: 10)
            .accessibilityHidden(true)
          Text(segment.title)
          Text("\(totals[segment] ?? 0)")
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        .font(.caption)
        .accessibilityElement(children: .combine)
      }
    }
  }
}

private struct SubjectDonut: View {
  var progress: SubjectProgress

  private var segments: [(segment: TaskProgressSegment, count: Int)] {
    TaskProgressSegment.allCases.compactMap { segment in
      let count = progress.counts[segment] ?? 0
      return count > 0 ? (segment, count) : nil
    }
  }

  var body: some View {
    VStack(spacing: 6) {
      Chart(segments, id: \.segment) { item in
        SectorMark(
          angle: .value("Aufgaben", item.count),
          innerRadius: .ratio(0.64),
          angularInset: 1
        )
        .cornerRadius(2)
        .foregroundStyle(item.segment.color)
      }
      .chartLegend(.hidden)
      .frame(width: 92, height: 92)
      .overlay {
        Text(progress.share, format: .percent.precision(.fractionLength(0)))
          .font(.subheadline.weight(.semibold))
          .monospacedDigit()
      }
      Text(progress.subject.title)
        .font(.caption.weight(.semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.75)
      Text("\(progress.done) von \(progress.total)")
        .font(.caption2)
        .monospacedDigit()
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(progress.subject.title)
    .accessibilityValue(accessibilityText)
  }

  private var accessibilityText: String {
    let parts = TaskProgressSegment.allCases.filter { $0 != .offen }.map { "\(progress.counts[$0] ?? 0) \($0.title.lowercased())" }
    return "\(progress.done) von \(progress.total) bearbeitet, " + parts.joined(separator: ", ")
  }
}
