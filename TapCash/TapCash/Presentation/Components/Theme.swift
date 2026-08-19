import SwiftUI

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
