import SwiftData
import SwiftUI

/// A grid with a live preview of every theme.
struct ThemePicker: View {
  @Binding var selection: AppTheme
  /// Themes that still have to be unlocked, with their price in stars.
  var lockedCosts: [AppTheme: Int] = [:]
  var onLockedSelection: (AppTheme) -> Void = { _ in }

  private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 16) {
      ForEach(AppTheme.allCases) { theme in
        Button {
          if lockedCosts[theme] != nil {
            onLockedSelection(theme)
          } else {
            selection = theme
          }
        } label: {
          ThemePreviewCard(theme: theme, isSelected: theme == selection, lockedCost: lockedCosts[theme])
        }
        .buttonStyle(.plain)
        .accessibilityLabel(theme.title)
        .accessibilityValue(lockedCosts[theme].map { "Gesperrt, \($0) Sterne" } ?? "")
        .accessibilityAddTraits(theme == selection ? .isSelected : [])
      }
    }
    .sensoryFeedback(.selection, trigger: selection)
  }
}

private struct ThemePreviewCard: View {
  var theme: AppTheme
  var isSelected: Bool
  var lockedCost: Int?

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      VStack(alignment: .leading, spacing: 6) {
        RoundedRectangle(cornerRadius: 6)
          .fill(.background)
          .frame(height: 30)
          .overlay(alignment: .leading) {
            HStack(spacing: 6) {
              Circle()
                .fill(theme.accent)
                .frame(width: 10, height: 10)
              Capsule()
                .fill(.secondary.opacity(0.4))
                .frame(width: 50, height: 6)
            }
            .padding(.horizontal, 8)
          }
        Capsule()
          .fill(theme.accent)
          .frame(height: 22)
          .overlay {
            Capsule()
              .fill(theme.onAccent.opacity(0.9))
              .frame(width: 36, height: 5)
          }
      }
      .padding(12)
      .frame(maxWidth: .infinity)
      .background(theme.background, in: .rect(cornerRadius: 14))
      .overlay {
        RoundedRectangle(cornerRadius: 14)
          .strokeBorder(isSelected ? theme.accent : Color.secondary.opacity(0.3), lineWidth: isSelected ? 3 : 1)
      }

      HStack(spacing: 6) {
        Text(theme.title)
          .font(.subheadline.weight(isSelected ? .semibold : .regular))
          .foregroundStyle(.primary)
        Spacer(minLength: 0)
        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(theme.accent)
            .accessibilityHidden(true)
        } else if let lockedCost {
          Label("\(lockedCost)", systemImage: "lock.fill")
            .font(.footnote.monospacedDigit())
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
        }
      }
    }
    .contentShape(.rect)
  }
}

/// The theme picker as its own screen, used from the settings.
struct ThemeSettingsView: View {
  @AppStorage(SettingsKey.theme) private var themeRaw = AppTheme.standard.rawValue
  @Query private var awards: [StarAward]
  @Query private var unlocks: [UnlockedReward]
  @State private var pendingItem: RewardItem?

  var body: some View {
    let wallet = StarWallet(awards: awards, unlocks: unlocks)
    let lockedCosts = Dictionary(uniqueKeysWithValues: AppTheme.allCases
      .filter { $0.rawValue != themeRaw && !wallet.isUnlocked(.theme($0)) }
      .map { ($0, $0.starCost) })

    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Label("Du hast \(wallet.balance) Sterne. Gesperrte Themen schaltest du mit Sternen frei.", systemImage: "star.fill")
          .font(.footnote)
          .foregroundStyle(.secondary)
        ThemePicker(selection: Binding {
          AppTheme(rawValue: themeRaw) ?? .standard
        } set: {
          themeRaw = $0.rawValue
        }, lockedCosts: lockedCosts) { theme in
          pendingItem = .theme(theme)
        }
      }
      .padding()
    }
    .unlockConfirmation(item: $pendingItem, wallet: wallet) { item in
      if case .theme(let theme) = item {
        themeRaw = theme.rawValue
      }
    }
    .themedBackground()
    .navigationTitle("Farbthema")
    .navigationBarTitleDisplayMode(.inline)
  }
}
