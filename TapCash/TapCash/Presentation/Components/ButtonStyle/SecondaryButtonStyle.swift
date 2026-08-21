//
//  SecondaryButtonStyle.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 21/08/26.
//

import SwiftUI

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
