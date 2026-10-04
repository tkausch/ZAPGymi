import SwiftUI

/// What the child sees right after earning stars.
struct RewardNotice: Identifiable, Equatable {
  var id: String
  var kind: RewardKind
  var title: String
  var stars: Int

  init(_ award: StarAward) {
    id = award.key
    kind = award.kind
    title = award.title
    stars = award.stars
  }
}

/// A full-screen celebration for closed rings and finished practice exams.
struct RewardCelebrationView: View {
  var notices: [RewardNotice]
  var onDismiss: () -> Void
  @State private var appeared = false
  @State private var burst = 0

  private var totalStars: Int { notices.map(\.stars).reduce(0, +) }

  private var headline: String {
    if notices.contains(where: { $0.kind == .allRings }) { return "Alle Ringe geschlossen!" }
    if notices.contains(where: { $0.kind == .ringClosed }) { return "Ring geschlossen!" }
    if notices.contains(where: { $0.kind == .examSimulation }) { return "Probeprüfung geschafft!" }
    return "Neue Sterne!"
  }

  var body: some View {
    ZStack {
      Color.black.opacity(appeared ? 0.4 : 0)
        .ignoresSafeArea()
        .onTapGesture(perform: onDismiss)
        .accessibilityHidden(true)

      VStack(spacing: 18) {
        starBurst
          .frame(height: 130)

        VStack(spacing: 6) {
          Text(headline)
            .font(.title2.bold())
            .multilineTextAlignment(.center)
          Text("+\(totalStars) Sterne")
            .font(.title3.weight(.semibold).monospacedDigit())
            .foregroundStyle(.secondary)
        }

        VStack(alignment: .leading, spacing: 10) {
          ForEach(notices) { notice in
            HStack(spacing: 10) {
              Image(systemName: notice.kind.systemImage)
                .foregroundStyle(.tint)
                .frame(width: 24)
                .accessibilityHidden(true)
              Text(notice.title)
                .font(.subheadline)
              Spacer(minLength: 8)
              Label("+\(notice.stars)", systemImage: "star.fill")
                .font(.subheadline.monospacedDigit())
                .labelStyle(StarLabelStyle())
            }
            .accessibilityElement(children: .combine)
          }
        }

        Button {
          onDismiss()
        } label: {
          Text("Super!")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .padding(24)
      .frame(maxWidth: 360)
      .background(.regularMaterial, in: .rect(cornerRadius: 28))
      .padding(24)
      .scaleEffect(appeared ? 1 : 0.85)
      .opacity(appeared ? 1 : 0)
      .accessibilityElement(children: .contain)
      .accessibilityAddTraits(.isModal)
    }
    .onAppear {
      withAnimation(.bouncy) { appeared = true }
      burst += 1
    }
    .sensoryFeedback(.success, trigger: burst)
  }

  private var starBurst: some View {
    ZStack {
      ForEach(0..<10) { index in
        let angle = Angle.degrees(Double(index) * 36)
        Image(systemName: "star.fill")
          .font(.system(size: index.isMultiple(of: 2) ? 16 : 11))
          .foregroundStyle(Color.star)
          .offset(x: appeared ? cos(angle.radians) * 70 : 0, y: appeared ? sin(angle.radians) * 70 : 0)
          .opacity(appeared ? 0.9 : 0)
          .scaleEffect(appeared ? 1 : 0.2)
          .animation(.spring(duration: 0.9, bounce: 0.4).delay(0.1), value: appeared)
      }
      Image(systemName: "star.fill")
        .font(.system(size: 72))
        .foregroundStyle(Color.star)
        .symbolEffect(.bounce, value: burst)
        .shadow(color: Color.star.opacity(0.5), radius: 12)
    }
    .accessibilityHidden(true)
  }
}

/// A short banner for small rewards, such as practising a mistake again.
struct RewardToast: View {
  var notices: [RewardNotice]

  private var text: String {
    let stars = notices.map(\.stars).reduce(0, +)
    let reason = notices.contains { $0.kind == .mistakeFixed } ? "Fehler korrigiert" : "Fehler wiederholt"
    return "+\(stars) Sterne · \(reason)"
  }

  var body: some View {
    Label(text, systemImage: "star.fill")
      .font(.subheadline.weight(.semibold))
      .labelStyle(StarLabelStyle())
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(.regularMaterial, in: .capsule)
      .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
      .onAppear {
        AccessibilityNotification.Announcement(text).post()
      }
  }
}

/// A label whose icon is drawn in the star colour, with the text in the normal text colour.
struct StarLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 4) {
      configuration.icon
        .foregroundStyle(Color.star)
      configuration.title
    }
  }
}
