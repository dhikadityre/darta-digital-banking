//
//  AmountScreen.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI
import CoreDomain

struct AmountScreen: View {
    @ObservedObject var viewModel: AmountScreenViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            EyebrowView(text: "Step 02 / Amount")
            Text("How much cash?")
                .font(.title.bold())
                .foregroundStyle(Palette.ink)

            if let limits = viewModel.limits {
                LimitsCardView(limits: limits)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.options, id: \.self) { amount in
                    Button {
                        viewModel.selectedAmountCents = amount
                    } label: {
                        Text(amount.rupiah)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .foregroundStyle(viewModel.selectedAmountCents == amount ? .white : Palette.navy)
                            .background(viewModel.selectedAmountCents == amount ? Palette.navy : Palette.surface)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.navy, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(amount <= viewModel.maxAllowed ? 1 : 0.4)
                    }
                    .disabled(amount > viewModel.maxAllowed)
                }
            }

            if !viewModel.isValid {
                Text("Choose an amount within your remaining daily limit (\(viewModel.maxAllowed.rupiah)).")
                    .foregroundStyle(.red).font(.footnote)
            }
            
            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.footnote)
            }

            Spacer()
            
            VStack(spacing: 12) {
                Button(viewModel.loading ? "Creating…" : "Create one-time QR") {
                    viewModel.createWithdrawal()
                }
                .buttonStyle(PrimaryButtonStyle(enabled: !viewModel.loading && viewModel.isValid))
                .disabled(viewModel.loading || !viewModel.isValid)
                
                Button("Cancel") {
                    viewModel.onBackSelected?()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(24)
    }
}
