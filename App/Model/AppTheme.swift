import SwiftUI

/// One of the colour themes the child can choose. Every colour has a light and a dark variant,
/// chosen so that text and tinted controls reach a contrast of at least 4.5:1.
enum AppTheme: String, CaseIterable, Identifiable {
  case neonNight
  case sunsetPop
  case oceanWave
  case limeZest
  case galaxy
  case calmPaper

  static let standard = AppTheme.oceanWave

  var id: String { rawValue }

  var title: String {
    switch self {
    case .neonNight: "Neon Night"
    case .sunsetPop: "Sunset Pop"
    case .oceanWave: "Ocean Wave"
    case .limeZest: "Lime Zest"
    case .galaxy: "Galaxy"
    case .calmPaper: "Calm Paper"
    }
  }

  /// Tint for buttons, links, icons and progress bars.
  var accent: Color {
    switch self {
    case .neonNight: Color(light: 0xA3106F, dark: 0xFF6EC7)
    case .sunsetPop: Color(light: 0xB0391A, dark: 0xFF8F66)
    case .oceanWave: Color(light: 0x0B5F9E, dark: 0x5AB8FF)
    case .limeZest: Color(light: 0x3A730C, dark: 0x8FD640)
    case .galaxy: Color(light: 0x5A3CC0, dark: 0xA993FF)
    case .calmPaper: Color(light: 0x7A5230, dark: 0xD6AB7E)
    }
  }

  /// Text on filled accent buttons. The light dark-mode accents need dark text to stay readable.
  var onAccent: Color {
    Color(light: 0xFFFFFF, dark: 0x000000)
  }

  /// A soft gradient behind lists and forms. Rows keep the system background, so text contrast is unchanged.
  var backgroundColors: [Color] {
    switch self {
    case .neonNight: [Color(light: 0xFBEFFF, dark: 0x0B0614), Color(light: 0xEAF6FF, dark: 0x050B14)]
    case .sunsetPop: [Color(light: 0xFFF1E6, dark: 0x140A06), Color(light: 0xFFE8EF, dark: 0x12060A)]
    case .oceanWave: [Color(light: 0xEAF6FF, dark: 0x04101A), Color(light: 0xE6FBF7, dark: 0x031412)]
    case .limeZest: [Color(light: 0xF3FCE6, dark: 0x0A1204), Color(light: 0xFFFDE6, dark: 0x11120A)]
    case .galaxy: [Color(light: 0xF1EDFF, dark: 0x0A0716), Color(light: 0xEAF0FF, dark: 0x060A18)]
    case .calmPaper: [Color(light: 0xFBF7EE, dark: 0x14110C), Color(light: 0xF6F0E3, dark: 0x100E0A)]
    }
  }

  var background: LinearGradient {
    LinearGradient(colors: backgroundColors, startPoint: .top, endPoint: .bottom)
  }
}

/// Whether the app follows the system appearance or stays light or dark.
enum AppearanceMode: String, CaseIterable, Identifiable {
  case automatic
  case light
  case dark

  var id: String { rawValue }

  var title: String {
    switch self {
    case .automatic: "Automatisch"
    case .light: "Hell"
    case .dark: "Dunkel"
    }
  }

  private var interfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .automatic: .unspecified
    case .light: .light
    case .dark: .dark
    }
  }

  /// Applies the mode to every window, including sheets that are already open.
  /// SwiftUI's preferredColorScheme cannot switch an open sheet back to the system setting.
  @MainActor
  func apply() {
    for scene in UIApplication.shared.connectedScenes {
      guard let windowScene = scene as? UIWindowScene else { continue }
      for window in windowScene.windows {
        window.overrideUserInterfaceStyle = interfaceStyle
      }
    }
  }
}

extension Color {
  /// A colour that switches between two hex values for light and dark appearance.
  init(light: UInt32, dark: UInt32) {
    self.init(uiColor: UIColor { traits in
      UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
    })
  }
}

private extension UIColor {
  convenience init(hex: UInt32) {
    self.init(
      red: CGFloat((hex >> 16) & 0xFF) / 255,
      green: CGFloat((hex >> 8) & 0xFF) / 255,
      blue: CGFloat(hex & 0xFF) / 255,
      alpha: 1
    )
  }
}

extension View {
  /// Replaces the plain list or form background with the theme gradient.
  func themedBackground() -> some View {
    modifier(ThemedBackground())
  }
}

private struct ThemedBackground: ViewModifier {
  @Environment(\.appTheme) private var theme

  func body(content: Content) -> some View {
    content
      .scrollContentBackground(.hidden)
      .background {
        theme.background
          .ignoresSafeArea()
      }
  }
}
