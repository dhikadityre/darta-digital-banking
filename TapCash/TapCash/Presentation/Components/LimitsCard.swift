//
//  LimitsCard.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import SwiftUI

struct LimitsCard: View {
    let limits: LimitsEntity
    
    private var fraction: Double {
        limits.dailyLimitCents == 0 ? 0 :
            min(1, Double(limits.withdrawnTodayCents) / Double(limits.dailyLimitCents))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Eyebrow(text: "Withdrawal limits")
            row("Per transaction", "\(limits.minCents.usd) – \(limits.maxCents.usd)")
            row("Daily limit", limits.dailyLimitCents.usd)
            row("Used today", limits.withdrawnTodayCents.usd)
            ProgressView(value: fraction)
                .tint(Palette.orange)
            Text("\(limits.remainingTodayCents.usd) remaining today")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Palette.navy)
        }
        .padding(16)
        .background(Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(Palette.muted)
            Spacer()
            Text(value).fontWeight(.bold).foregroundStyle(Palette.ink)
        }
    }
}
