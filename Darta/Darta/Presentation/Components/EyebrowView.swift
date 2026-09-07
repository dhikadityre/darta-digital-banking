//
//  EyebrowView.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 21/08/26.
//

import SwiftUI

public struct EyebrowView: View {
    let text: String
    var iconName: String? = nil

    public init(text: String, iconName: String? = nil) {
        self.text = text
        self.iconName = iconName
    }

    public var body: some View {
        HStack(spacing: 6) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Palette.amber)
            } else {
                Circle()
                    .fill(Palette.amber)
                    .frame(width: 5, height: 5)
            }

            Text(text.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.8)
                .foregroundStyle(Palette.amberLight)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Palette.amber.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(Palette.amber.opacity(0.25), lineWidth: 0.8)
        )
    }
}
