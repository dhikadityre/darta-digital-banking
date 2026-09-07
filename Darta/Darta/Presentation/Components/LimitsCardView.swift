//
//  LimitsCardView.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import SwiftUI
import CoreDomain

public struct LimitsCardView: View {
    public let limits: LimitsEntity

    public init(limits: LimitsEntity) {
        self.limits = limits
    }

    private var fraction: Double {
        limits.dailyLimitCents == 0 ? 0 :
            min(1, Double(limits.withdrawnTodayCents) / Double(limits.dailyLimitCents))
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // MARK: - Header
            HStack {
                EyebrowView(text: "Withdrawal limits", iconName: "chart.bar.fill")
                Spacer()
                Text("\(Int(fraction * 100))% used")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Palette.inkSecondary)
            }

            // MARK: - Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Palette.surfaceElevated)
                            .frame(height: 8)

                        Capsule()
                            .fill(Palette.goldGradient)
                            .frame(width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(fraction))), height: 8)
                            .shadow(color: Palette.amber.opacity(0.4), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(limits.remainingTodayCents.rupiah) remaining today")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Palette.amberLight)
                    Spacer()
                    Text("Daily \(limits.dailyLimitCents.rupiah)")
                        .font(.caption)
                        .foregroundStyle(Palette.muted)
                }
            }

            Divider()
                .background(Palette.border)

            // MARK: - Detail Rows
            VStack(spacing: 8) {
                row(icon: "arrow.left.arrow.right", label: "Per transaction", value: "\(limits.minCents.rupiah) – \(limits.maxCents.rupiah)")
                row(icon: "clock.arrow.circlepath", label: "Withdrawn today", value: limits.withdrawnTodayCents.rupiah)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Palette.cardGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Palette.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    private func row(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Palette.muted)
                .frame(width: 16)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Palette.inkSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Palette.ink)
        }
    }
}
