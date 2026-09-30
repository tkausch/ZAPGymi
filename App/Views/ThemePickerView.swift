import SwiftUI

/// A grid with a live preview of every theme.
struct ThemePicker: View {
  @Binding var selection: AppTheme

  private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 16) {
      ForEach(AppTheme.allCases) { theme in
        Button {
          selection = theme
        } label: {
          ThemePreviewCard(theme: theme, isSelected: theme == selection)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(theme.title)
        .accessibilityAddTraits(theme == selection ? .isSelected : [])
      }
    }
    .sensoryFeedback(.selection, trigger: selection)
  }
}

private struct ThemePreviewCard: View {
  var theme: AppTheme
  var isSelected: Bool

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
        }
      }
    }
    .contentShape(.rect)
  }
}

/// The theme picker as its own screen, used from the settings.
struct ThemeSettingsView: View {
  @AppStorage(SettingsKey.theme) private var themeRaw = AppTheme.standard.rawValue

  var body: some View {
    ScrollView {
      ThemePicker(selection: Binding {
        AppTheme(rawValue: themeRaw) ?? .standard
      } set: {
        themeRaw = $0.rawValue
      })
      .padding()
    }
    .themedBackground()
    .navigationTitle("Farbthema")
    .navigationBarTitleDisplayMode(.inline)
  }
}
