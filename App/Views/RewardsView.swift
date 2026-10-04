import SwiftData
import SwiftUI

/// Stars, the mascot and everything the child can unlock.
struct RewardsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \StarAward.date, order: .reverse) private var awards: [StarAward]
  @Query private var unlocks: [UnlockedReward]
  @AppStorage(SettingsKey.theme) private var themeRaw = AppTheme.standard.rawValue
  @AppStorage(MascotAccessory.Slot.head.settingsKey) private var headRaw = ""
  @AppStorage(MascotAccessory.Slot.face.settingsKey) private var faceRaw = ""
  @State private var pendingItem: RewardItem?

  var body: some View {
    let wallet = StarWallet(awards: awards, unlocks: unlocks)

    List {
      Section {
        mascotHeader(wallet)
      }

      Section {
        ForEach(AppTheme.allCases) { theme in
          themeRow(theme, wallet: wallet)
        }
      } header: {
        Text("Farbthemen")
      } footer: {
        Text("Ein Thema verändert die Farben der ganzen App.")
      }

      Section {
        ForEach(MascotAccessory.allCases) { accessory in
          accessoryRow(accessory, wallet: wallet)
        }
      } header: {
        Text("Zubehör für \(MascotStage.mascotName)")
      } footer: {
        Text("\(MascotStage.mascotName) trägt eine Sache auf dem Kopf und eine im Gesicht.")
      }

      Section {
        ForEach(RewardKind.allCases) { kind in
          LabeledContent {
            Label("\(kind.stars)", systemImage: "star.fill")
              .labelStyle(StarLabelStyle())
              .monospacedDigit()
          } label: {
            Label(kind.title, systemImage: kind.systemImage)
          }
          .accessibilityElement(children: .combine)
        }
      } header: {
        Text("So verdienst du Sterne")
      } footer: {
        Text("Sterne fürs Wiederholen gibt es pro Aufgabe einmal am Tag. Ein Wochenring bringt Sterne, wenn das Ziel nicht zu tief eingestellt ist.")
      }

      if !awards.isEmpty {
        Section("Zuletzt verdient") {
          ForEach(awards.prefix(15)) { award in
            LabeledContent {
              Text("+\(award.stars)")
                .monospacedDigit()
            } label: {
              VStack(alignment: .leading, spacing: 2) {
                Text(award.title)
                Text(award.date.formatted(date: .abbreviated, time: .omitted))
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
          }
        }
      }
    }
    .themedBackground()
    .navigationTitle("Sterne")
    .unlockConfirmation(item: $pendingItem, wallet: wallet, onUnlocked: use)
  }

  private func mascotHeader(_ wallet: StarWallet) -> some View {
    let stage = wallet.mascotStage
    return VStack(spacing: 12) {
      WornMascotView(stage: stage, size: 140)
      VStack(spacing: 4) {
        Text("\(MascotStage.mascotName) · \(stage.title)")
          .font(.headline)
        if let next = stage.next {
          ProgressView(value: Double(wallet.earned - stage.minimumStars), total: Double(next.minimumStars - stage.minimumStars))
            .frame(maxWidth: 220)
          Text("Noch \(next.minimumStars - wallet.earned) Sterne, dann wird \(MascotStage.mascotName) zum \(next.title).")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        } else {
          Text("\(MascotStage.mascotName) ist ausgewachsen.")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
      Label("\(wallet.balance) Sterne", systemImage: "star.fill")
        .font(.title2.bold().monospacedDigit())
        .labelStyle(StarLabelStyle())
        .padding(.top, 4)
      Text("Insgesamt verdient: \(wallet.earned)")
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
  }

  private func themeRow(_ theme: AppTheme, wallet: StarWallet) -> some View {
    let item = RewardItem.theme(theme)
    let isSelected = themeRaw == theme.rawValue
    let isUnlocked = isSelected || wallet.isUnlocked(item)
    return Button {
      if isUnlocked {
        themeRaw = theme.rawValue
      } else {
        pendingItem = item
      }
    } label: {
      HStack(spacing: 12) {
        Circle()
          .fill(theme.background)
          .overlay {
            Circle()
              .fill(theme.accent)
              .padding(8)
          }
          .overlay {
            Circle().strokeBorder(.secondary.opacity(0.3))
          }
          .frame(width: 34, height: 34)
          .accessibilityHidden(true)
        Text(theme.title)
          .foregroundStyle(.primary)
        Spacer(minLength: 8)
        trailing(isUnlocked: isUnlocked, isActive: isSelected, cost: item.cost)
      }
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .accessibilityHint(isUnlocked ? "Auswählen" : "Mit Sternen freischalten")
  }

  private func accessoryRow(_ accessory: MascotAccessory, wallet: StarWallet) -> some View {
    let item = RewardItem.accessory(accessory)
    let isUnlocked = wallet.isUnlocked(item)
    let isWorn = wornRaw(for: accessory.slot) == accessory.rawValue
    return Button {
      if !isUnlocked {
        pendingItem = item
      } else {
        setWorn(isWorn ? nil : accessory)
      }
    } label: {
      HStack(spacing: 12) {
        Image(systemName: accessory.systemImage)
          .font(.title3)
          .foregroundStyle(.tint)
          .frame(width: 34)
          .accessibilityHidden(true)
        Text(accessory.title)
          .foregroundStyle(.primary)
        Spacer(minLength: 8)
        trailing(isUnlocked: isUnlocked, isActive: isWorn, cost: item.cost, activeTitle: "Trägt", inactiveTitle: "Anziehen")
      }
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .accessibilityHint(!isUnlocked ? "Mit Sternen freischalten" : (isWorn ? "Ablegen" : "Anziehen"))
  }

  @ViewBuilder
  private func trailing(isUnlocked: Bool, isActive: Bool, cost: Int, activeTitle: String = "Aktiv", inactiveTitle: String = "Auswählen") -> some View {
    if isActive {
      Label(activeTitle, systemImage: "checkmark.circle.fill")
        .font(.subheadline)
        .foregroundStyle(.tint)
    } else if isUnlocked {
      Text(inactiveTitle)
        .font(.subheadline)
        .foregroundStyle(.tint)
    } else {
      Label("\(cost)", systemImage: "lock.fill")
        .font(.subheadline.monospacedDigit())
        .foregroundStyle(.secondary)
    }
  }

  private func wornRaw(for slot: MascotAccessory.Slot) -> String {
    slot == .head ? headRaw : faceRaw
  }

  private func setWorn(_ accessory: MascotAccessory?, slot: MascotAccessory.Slot? = nil) {
    guard let slot = slot ?? accessory?.slot else { return }
    let raw = accessory?.rawValue ?? ""
    withAnimation(.bouncy) {
      if slot == .head { headRaw = raw } else { faceRaw = raw }
    }
  }

  private func use(_ item: RewardItem) {
    switch item {
    case .theme(let theme): themeRaw = theme.rawValue
    case .accessory(let accessory): setWorn(accessory)
    }
  }
}

extension View {
  /// Asks before spending stars on an extra, or explains how many stars are still missing.
  func unlockConfirmation(item: Binding<RewardItem?>, wallet: StarWallet, onUnlocked: @escaping (RewardItem) -> Void) -> some View {
    modifier(UnlockConfirmation(item: item, wallet: wallet, onUnlocked: onUnlocked))
  }
}

private struct UnlockConfirmation: ViewModifier {
  @Binding var item: RewardItem?
  var wallet: StarWallet
  var onUnlocked: (RewardItem) -> Void
  @Environment(\.modelContext) private var modelContext
  @State private var unlockCount = 0

  func body(content: Content) -> some View {
    let isPresented = Binding { item != nil } set: { if !$0 { item = nil } }
    content
      .alert(title, isPresented: isPresented, presenting: item) { item in
        if wallet.canAfford(item) {
          Button("Freischalten") {
            RewardEngine.unlock(item, in: modelContext)
            unlockCount += 1
            onUnlocked(item)
          }
          Button("Abbrechen", role: .cancel) {}
        } else {
          Button("OK", role: .cancel) {}
        }
      } message: { item in
        if wallet.canAfford(item) {
          Text("Das kostet \(item.cost) Sterne. Du hast \(wallet.balance).")
        } else {
          Text("Dafür brauchst du \(item.cost) Sterne. Dir fehlen noch \(item.cost - wallet.balance). Schliesse Wochenringe, mache Probeprüfungen oder wiederhole deine Fehler.")
        }
      }
      .sensoryFeedback(.success, trigger: unlockCount)
  }

  private var title: String {
    guard let item else { return "" }
    return wallet.canAfford(item) ? "\(item.title) freischalten?" : "Noch nicht genug Sterne"
  }
}
