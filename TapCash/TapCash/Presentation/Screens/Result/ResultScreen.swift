//
//  ResultScreen.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI

struct ResultScreen: View {
    @ObservedObject var viewModel: ResultScreenViewModel

    var body: some View {
        VStack(spacing: 14) {
            if let result = viewModel.dispenseResult {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56)).foregroundStyle(Palette.green)
                EyebrowView(text: "Withdrawal complete")
                Text("Cash dispensed").font(.title.bold()).foregroundStyle(Palette.ink)
                Text(result.amountCents.rupiah)
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink)
                Text("Remaining balance \(result.remainingBalanceCents.rupiah)")
                    .foregroundStyle(Palette.muted)
                Text("Txn \(result.transactionId.prefix(8))…").font(.footnote.monospaced())
                Spacer()
                Button("Done") {
                    viewModel.done()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(24)
    }
}
