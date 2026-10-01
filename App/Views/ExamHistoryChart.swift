import Charts
import SwiftUI

struct ExamResultPoint: Identifiable {
  var id: UUID
  var date: Date
  var subject: Subject
  var share: Double
}

/// Results of the graded simulations over time, one line per subject, with a target line.
struct ExamHistoryChart: View {
  var points: [ExamResultPoint]
  var target: Double

  /// Categorical colours (blue, orange) checked for colour blindness; points also differ by shape.
  private func color(for subject: Subject) -> Color {
    subject == .mathematik ? Color(light: 0x2A78D6, dark: 0x3987E5) : Color(light: 0xEB6834, dark: 0xD95926)
  }

  /// Only subjects with results appear in the legend.
  private var subjects: [Subject] {
    Subject.gradable.filter { subject in points.contains { $0.subject == subject } }
  }

  var body: some View {
    Chart {
      RuleMark(y: .value("Ziel", target * 100))
        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
        .foregroundStyle(.secondary)
        .annotation(position: .top, alignment: .leading) {
          Text("Ziel \(Int((target * 100).rounded())) %")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      ForEach(points) { point in
        LineMark(
          x: .value("Datum", point.date),
          y: .value("Ergebnis", point.share * 100),
          series: .value("Fach", point.subject.title)
        )
        .lineStyle(StrokeStyle(lineWidth: 2))
        .foregroundStyle(by: .value("Fach", point.subject.title))
        PointMark(
          x: .value("Datum", point.date),
          y: .value("Ergebnis", point.share * 100)
        )
        .foregroundStyle(by: .value("Fach", point.subject.title))
        .symbol(point.subject == .mathematik ? BasicChartSymbolShape.circle : BasicChartSymbolShape.square)
        .symbolSize(50)
        .accessibilityLabel("\(point.subject.title), \(point.date.formatted(date: .abbreviated, time: .omitted))")
        .accessibilityValue("\(Int((point.share * 100).rounded())) Prozent")
      }
    }
    .chartForegroundStyleScale(domain: subjects.map(\.title), range: subjects.map(color(for:)))
    .chartYScale(domain: 0...100)
    .chartYAxis {
      AxisMarks(values: [0, 25, 50, 75, 100]) { value in
        AxisGridLine()
        AxisValueLabel {
          if let percent = value.as(Int.self) {
            Text("\(percent) %")
          }
        }
      }
    }
    .chartXAxis {
      AxisMarks(values: .automatic(desiredCount: 4)) { _ in
        AxisGridLine()
        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
      }
    }
    .chartLegend(position: .bottom, alignment: .leading)
    .frame(height: 210)
  }
}
