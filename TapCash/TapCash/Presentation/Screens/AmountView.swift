//
//  AmountView.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import SwiftUI

struct AmountView: View {
    @ObservedObject var vm: WithdrawalViewModel
    @State private var selected = 4000
    private let options = [2000, 4000, 6000, 10000, 20000]

    private var maxAllowed: Int {
        min(vm.limits?.maxCents ?? 20000, vm.limits?.remainingTodayCents ?? .max)
    }
    private var minAllowed: Int { vm.limits?.minCents ?? 2000 }
    private var valid: Bool { selected >= minAllowed && selected <= maxAllowed }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Eyebrow(text: "Step 02 / Amount")
            Text("How much cash?")
                .font(.title.bold())
                .foregroundStyle(Palette.ink)

            if let limits = vm.limits { LimitsCard(limits: limits) }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(options, id: \.self) { amount in
                    Button {
                        selected = amount
                    } label: {
                        Text(amount.usd)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .foregroundStyle(selected == amount ? .white : Palette.navy)
                            .background(selected == amount ? Palette.navy : Palette.surface)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.navy, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(amount <= maxAllowed ? 1 : 0.4)
                    }
                    .disabled(amount > maxAllowed)
                }
            }

            if !valid {
                Text("Choose an amount within your remaining daily limit (\(maxAllowed.usd)).")
                    .foregroundStyle(.red).font(.footnote)
            }
            if let error = vm.errorMessage {
                Text(error).foregroundStyle(.red).font(.footnote)
            }

            Spacer()
            Button(vm.loading ? "Creating…" : "Create one-time QR") {
                vm.createWithdrawal(amountCents: selected)
            }
            .buttonStyle(PrimaryButtonStyle(enabled: !vm.loading && valid))
            .disabled(vm.loading || !valid)
        }
        .padding(24)
    }
}
