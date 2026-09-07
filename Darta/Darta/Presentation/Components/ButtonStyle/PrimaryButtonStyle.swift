//
//  PrimaryButtonStyle.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 21/08/26.
//

import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    public var enabled: Bool = true

    public init(enabled: Bool = true) {
        self.enabled = enabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(enabled ? Color(red: 0x0E/255, green: 0x0E/255, blue: 0x12/255) : Palette.inkSecondary)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                Group {
                    if enabled {
                        Palette.goldGradient
                    } else {
                        Palette.surfaceElevated
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(enabled ? Color.clear : Palette.border, lineWidth: 1)
            )
            .shadow(
                color: enabled ? Palette.amber.opacity(0.32) : Color.clear,
                radius: 12,
                x: 0,
                y: 4
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
