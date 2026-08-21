import SwiftUI
import UIKit

/// TapCash "Receipt / Signal" palette.
enum Palette {
    static let navy = Color(red: 0x15/255, green: 0x32/255, blue: 0x4A/255)
    static let orange = Color(red: 0xE4/255, green: 0x55/255, blue: 0x2F/255)
    static let canvas = Color(red: 0xF3/255, green: 0xEF/255, blue: 0xE7/255)
    static let surface = Color(red: 0xFF/255, green: 0xFD/255, blue: 0xF8/255)
    static let ink = Color(red: 0x18/255, green: 0x21/255, blue: 0x2B/255)
    static let muted = Color(red: 0x52/255, green: 0x60/255, blue: 0x6D/255)
    static let green = Color(red: 0x17/255, green: 0x6B/255, blue: 0x4D/255)
}

struct Eyebrow: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.bold))
            .tracking(2)
            .foregroundStyle(Palette.muted)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(enabled ? Palette.orange : Palette.orange.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var enabled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(enabled ? Palette.navy : Palette.navy.opacity(0.4))
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Color.clear)
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(enabled ? Palette.navy : Palette.navy.opacity(0.4), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

// MARK: - Color Luminance Helpers
extension Color {
    /// Determines whether the color is light/bright based on its relative luminance.
    var isLight: Bool {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        let uiColor = UIColor(self)
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            // YIQ luminance formula: standard threshold is 0.5
            let luminance = 0.299 * r + 0.587 * g + 0.114 * b
            return luminance > 0.5
        }
        return true // Default to light
    }
}

// MARK: - Adaptive Status Bar View Modifier
struct AdaptiveStatusBarModifier: ViewModifier {
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(backgroundColor.isLight ? .light : .dark)
    }
}

extension View {
    /// Dynamically sets the status bar style (via preferredColorScheme) based on the brightness of the background color.
    func adaptiveStatusBar(backgroundColor: Color) -> some View {
        self.modifier(AdaptiveStatusBarModifier(backgroundColor: backgroundColor))
    }
}
