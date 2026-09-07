//
//  DartaCard.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI

public struct DartaCard<Content: View>: View {
    private let content: Content
    private let cornerRadius: CGFloat
    private let isGoldAccent: Bool
    private let padding: CGFloat

    public init(
        cornerRadius: CGFloat = 16,
        isGoldAccent: Bool = false,
        padding: CGFloat = 18,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.isGoldAccent = isGoldAccent
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isGoldAccent ? Palette.goldCardGradient : Palette.cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isGoldAccent ? Palette.amber.opacity(0.3) : Palette.border,
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
    }
}

// MARK: - View Modifier Convenience
public extension View {
    func dartaCardStyle(
        cornerRadius: CGFloat = 16,
        isGoldAccent: Bool = false,
        padding: CGFloat = 18
    ) -> some View {
        DartaCard(
            cornerRadius: cornerRadius,
            isGoldAccent: isGoldAccent,
            padding: padding
        ) {
            self
        }
    }
}
