//
//  ResultView.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var vm: WithdrawalViewModel
    var body: some View {
        VStack(spacing: 14) {
            if let result = vm.dispenseResult {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56)).foregroundStyle(Palette.green)
                Eyebrow(text: "Withdrawal complete")
                Text("Cash dispensed").font(.title.bold()).foregroundStyle(Palette.ink)
                Text(result.amountCents.usd)
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink)
                Text("Remaining balance \(result.remainingBalanceCents.usd)")
                    .foregroundStyle(Palette.muted)
                Text("Txn \(result.transactionId.prefix(8))…").font(.footnote.monospaced())
                Spacer()
                Button("Done") { vm.finish() }.buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(24)
    }
}
