//
//  AdaptiveStatusBarModifier.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 21/08/26.
//

import SwiftUI

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
