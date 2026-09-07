//
//  BalanceCardView.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI
import CoreDomain

public struct BalanceCardView: View {
    let displayName: String
    let balanceCents: Int

    public init(displayName: String, balanceCents: Int) {
        self.displayName = displayName
        self.balanceCents = balanceCents
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // MARK: - Card Header
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image(systemName: "creditcard.and.123")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Palette.amber)
                    Text("DARTA")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(Palette.ink)
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Palette.green)
                        .frame(width: 6, height: 6)
                    Text("SIMULATED")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(Palette.inkSecondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    Capsule()
                        .stroke(Palette.border, lineWidth: 1)
                )
            }

            // MARK: - Balance Amount
            VStack(alignment: .leading, spacing: 6) {
                Text("Available Balance")
                    .font(.caption.weight(.medium))
                    .tracking(0.5)
                    .foregroundStyle(Palette.inkSecondary)

                Text(balanceCents.rupiah)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.ink)
                    .contentTransition(.numericText())
            }

            // MARK: - Card Footer (Chip + Cardholder Name)
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CARDHOLDER")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(Palette.muted)

                    Text(displayName.isEmpty ? "Darta Customer" : displayName.uppercased())
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 12) {
                    // Contactless Symbol
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Palette.amber.opacity(0.8))

                    // EMV Chip Icon Visual
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Palette.goldGradient)
                            .frame(width: 32, height: 24)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                            .frame(width: 24, height: 16)
                    }
                }
            }
        }
        .padding(22)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Palette.goldCardGradient)
                
                // Subtle Ambient Radial Light
                RadialGradient(
                    colors: [Palette.amber.opacity(0.18), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 200
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Palette.amber.opacity(0.45), Palette.border, Palette.amber.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Palette.amber.opacity(0.12), radius: 20, x: 0, y: 10)
        .shadow(color: Color.black.opacity(0.5), radius: 15, x: 0, y: 8)
    }
}
