import SwiftData
import SwiftUI

/// «Meine Stärken»: how well the child does in each math category, as a radar chart and a list.
struct StrengthsView: View {
  var track: ExamTrack
  @Environment(\.catalog) private var catalog
  @Environment(\.appTheme) private var theme
  @Query private var attempts: [Attempt]

  /// More axes than this make the chart unreadable on a phone.
  private let maximumAxes = 8

  var body: some View {
    let mathTasks = catalog.tasks(for: track, subject: .mathematik)
    let summary = ProgressSummary(attempts: attempts)
    let stats = Dictionary(uniqueKeysWithValues: summary.topicStats(for: mathTasks, subject: .mathematik).map { ($0.topic, $0) })
    let axisTopics = TopicStatistics(tasks: mathTasks).topics.prefix(maximumAxes).map(\.topic)
    let attempted = stats.values.filter { $0.attempted > 0 }.sorted { $0.score > $1.score }
    let strengths = attempted.filter { $0.hasEnoughData && $0.score >= 0.7 }.prefix(3)

    List {
      if attempted.isEmpty {
        Section {
          ContentUnavailableView {
            Label("Noch keine Stärken sichtbar", systemImage: "chart.pie")
          } description: {
            Text("Löse Mathematikaufgaben und schätze dich ein. Dann zeigt dir das Netzdiagramm, in welchen Bereichen du stark bist.")
          }
        }
      } else {
        Section {
          RadarChart(
            axes: axisTopics.map { topic in
              let stat = stats[topic]
              return RadarAxis(
                label: Self.shortLabel(for: topic),
                value: stat?.attempted ?? 0 > 0 ? stat?.score ?? 0 : 0,
                isTentative: !(stat?.hasEnoughData ?? false),
                isOpen: (stat?.attempted ?? 0) == 0
              )
            },
            color: theme.accent
          )
          .padding(.vertical, 8)
          .accessibilityElement(children: .ignore)
          .accessibilityLabel("Netzdiagramm deiner Stärken in Mathematik")
          .accessibilityValue(accessibilitySummary(topics: axisTopics, stats: stats))
        } header: {
          Text("Mathematik")
        } footer: {
          Text("Je weiter aussen ein Punkt liegt, desto mehr Punkte hast du in diesem Bereich erreicht. Gezeigt werden die \(axisTopics.count) Bereiche mit den meisten Prüfungspunkten. Hohle Punkte: weniger als \(TopicStat.minimumAttempts) eingeschätzte Aufgaben, der Wert ist noch unsicher. «Noch offen»: in diesem Bereich hast du noch nichts gelöst.")
        }

        Section("Deine Stärken") {
          if strengths.isEmpty {
            Text(track.usesSimpleLanguage
              ? "Noch keine klare Stärke. Löse in einem Bereich mindestens \(TopicStat.minimumAttempts) Aufgaben, dann siehst du sie hier."
              : "Noch keine Stärke mit genug Daten (mindestens \(TopicStat.minimumAttempts) Aufgaben und 70 %).")
              .foregroundStyle(.secondary)
          } else {
            ForEach(strengths) { stat in
              Label {
                LabeledContent(stat.topic) {
                  Text(stat.score, format: .percent.precision(.fractionLength(0)))
                    .monospacedDigit()
                }
              } icon: {
                Image(systemName: "star.fill")
                  .foregroundStyle(.tint)
              }
            }
          }
        }

        Section("Alle Bereiche") {
          ForEach(attempted) { stat in
            NavigationLink(value: TaskListRoute.mathTopic(track, stat.topic)) {
              VStack(alignment: .leading, spacing: 4) {
                LabeledContent(stat.topic) {
                  if stat.hasEnoughData {
                    Text(stat.score, format: .percent.precision(.fractionLength(0)))
                      .monospacedDigit()
                  } else {
                    Text("wenig Daten")
                  }
                }
                Text(stat.attempted == 1 ? "1 Aufgabe eingeschätzt" : "\(stat.attempted) Aufgaben eingeschätzt")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
          }
        }
      }
    }
    .themedBackground()
    .navigationTitle("Meine Stärken")
  }

  private func accessibilitySummary(topics: [String], stats: [String: TopicStat]) -> String {
    topics.map { topic in
      guard let stat = stats[topic], stat.attempted > 0 else { return "\(topic): noch nicht geübt" }
      return "\(topic): \(Int((stat.score * 100).rounded())) Prozent"
    }
    .joined(separator: ", ")
  }

  /// Shortens long category names for the chart, e.g. «Kombinatorik und systematisches Probieren» to «Kombinatorik».
  static func shortLabel(for topic: String) -> String {
    let separators = [" und ", ", ", "/", " ("]
    var label = topic
    for separator in separators {
      if let range = label.range(of: separator) {
        label = String(label[..<range.lowerBound])
      }
    }
    return label
  }
}
