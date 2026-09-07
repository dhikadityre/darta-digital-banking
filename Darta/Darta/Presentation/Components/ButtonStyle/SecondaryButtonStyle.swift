//
//  SecondaryButtonStyle.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 21/08/26.
//

import SwiftUI

public struct SecondaryButtonStyle: ButtonStyle {
    public var enabled: Bool = true

    public init(enabled: Bool = true) {
        self.enabled = enabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.medium))
            .foregroundStyle(enabled ? Palette.ink : Palette.muted)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Palette.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        enabled ? Palette.amber.opacity(0.3) : Palette.border,
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
