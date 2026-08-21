//
//  PrimaryButtonStyle.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 21/08/26.
//

import SwiftUI

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
