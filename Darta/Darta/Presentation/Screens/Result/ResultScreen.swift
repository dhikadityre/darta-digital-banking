//
//  ResultScreen.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI
import CoreDomain

struct ResultScreen: View {
    @ObservedObject var viewModel: ResultScreenViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                if let result = viewModel.dispenseResult {
                    Spacer(minLength: 16)

                    // MARK: - Success Badge & Glow
                    ZStack {
                        Circle()
                            .fill(Palette.green.opacity(0.15))
                            .frame(width: 90, height: 90)

                        Circle()
                            .stroke(Palette.green.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 90, height: 90)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(Palette.green)
                            .shadow(color: Palette.green.opacity(0.4), radius: 10, x: 0, y: 4)
                    }
                    .padding(.top, 12)

                    // MARK: - Header
                    VStack(spacing: 8) {
                        EyebrowView(text: "Withdrawal Complete", iconName: "sparkles")

                        Text("Cash Dispensed!")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Palette.ink)

                        Text(result.amountCents.rupiah)
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(Palette.amberLight)
                    }

                    // MARK: - Digital Receipt Card
                    VStack(spacing: 16) {
                        HStack {
                            Text("RECEIPT SUMMARY")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(Palette.inkSecondary)

                            Spacer()

                            Text("SIMULATED")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Palette.green.opacity(0.15))
                                .foregroundStyle(Palette.green)
                                .clipShape(Capsule())
                        }

                        Divider()
                            .background(Palette.border)

                        receiptRow(label: "Dispensed Amount", value: result.amountCents.rupiah, isHighlighted: true)
                        receiptRow(label: "Remaining Balance", value: result.remainingBalanceCents.rupiah, isHighlighted: false)
                        receiptRow(label: "Status", value: "Dispensed", isHighlighted: false)
                        receiptRow(label: "Transaction Ref", value: "#\(result.transactionId.prefix(12))", isHighlighted: false)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Palette.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Palette.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)

                    // MARK: - Done Button
                    Button {
                        viewModel.done()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Return to Home")
                            Image(systemName: "house.fill")
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 8)

                    Spacer(minLength: 24)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(
            ZStack {
                Palette.canvas.ignoresSafeArea()
                Palette.radialAmbient.ignoresSafeArea()
            }
        )
    }

    private func receiptRow(label: String, value: String, isHighlighted: Bool) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Palette.inkSecondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(isHighlighted ? .bold : .medium))
                .foregroundStyle(isHighlighted ? Palette.amberLight : Palette.ink)
        }
    }
}
