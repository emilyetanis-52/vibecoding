import SwiftUI

/// Align brand palette. See BRAND.md for the source of truth.
extension Color {
    static let alignPrimaryIndigo = Color(hex: 0x042C53)
    static let alignSecondaryIndigo = Color(hex: 0x185FA5)
    static let alignAccentAmber = Color(hex: 0xBA7517)
    static let alignAccentBrightAmber = Color(hex: 0xFAC775)
    static let alignBase = Color(hex: 0xFBF7EF)
    static let alignSuccessTint = Color(hex: 0xE6F1FB)
    static let alignWarningTint = Color(hex: 0xFAEEDA)

    /// The "i" accent color, adapted for the current color scheme.
    static func alignAccent(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .alignAccentBrightAmber : .alignAccentAmber
    }

    /// The wordmark's non-accent letters, adapted for the current color scheme.
    static func alignForeground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .alignBase : .alignPrimaryIndigo
    }

    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
