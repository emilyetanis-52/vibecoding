import SwiftUI

/// The static "Al[i]gn" wordmark, per BRAND.md: medium weight, the "i" in
/// amber, everything else in the primary/base color for the current scheme.
///
/// Uses the system font (SF Pro) rather than Söhne/General Sans/Inter --
/// no brand font file has been supplied or licensed for embedding yet.
struct AlignWordmark: View {
    var size: CGFloat = 28

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let foreground = Color.alignForeground(for: colorScheme)
        let accent = Color.alignAccent(for: colorScheme)
        let font = Font.system(size: size, weight: .medium, design: .default)

        (
            Text("Al").foregroundColor(foreground)
                + Text("i").foregroundColor(accent)
                + Text("gn").foregroundColor(foreground)
        )
        .font(font)
        .kerning(-0.5)
    }
}
