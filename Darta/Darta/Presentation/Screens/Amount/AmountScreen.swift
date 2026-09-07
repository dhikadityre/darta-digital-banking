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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                // MARK: - Navigation & Step Header
                HStack {
                    Button {
                        viewModel.onBackSelected?()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("Back")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(Palette.amberLight)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Palette.surfaceElevated)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Palette.border, lineWidth: 1))
                    }

                    Spacer()

                    EyebrowView(text: "Step 02 / 03", iconName: "banknote.fill")
                }
                .padding(.top, 8)

                // MARK: - Title
                VStack(alignment: .leading, spacing: 6) {
                    Text("Choose Amount")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.ink)

                    Text("Select how much cash you want to withdraw.")
                        .font(.subheadline)
                        .foregroundStyle(Palette.inkSecondary)
                }

                // MARK: - Limits Card
                if let limits = viewModel.limits {
                    LimitsCardView(limits: limits)
                }

                // MARK: - Amount Selection Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("QUICK DENOMINATIONS")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(Palette.inkSecondary)
                        .padding(.horizontal, 4)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(viewModel.options, id: \.self) { amount in
                            amountChip(for: amount)
                        }
                    }
                }

                // MARK: - Validation & Error Alerts
                if !viewModel.isValid {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(Palette.red)
                        Text("Selected amount exceeds remaining limit (\(viewModel.maxAllowed.rupiah)).")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Palette.red)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Palette.red.opacity(0.12))
                    )
                }

                if let error = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Palette.red)
                        Text(error)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Palette.red)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Palette.red.opacity(0.12))
                    )
                }

                // MARK: - Action Buttons
                VStack(spacing: 12) {
                    Button {
                        viewModel.createWithdrawal()
                    } label: {
                        HStack(spacing: 8) {
                            if viewModel.loading {
                                ProgressView()
                                    .tint(Color(red: 0x0D/255, green: 0x0D/255, blue: 0x12/255))
                                Text("Creating Ticket…")
                            } else {
                                Text("Generate QR Ticket")
                                Image(systemName: "qrcode")
                                    .font(.headline.weight(.bold))
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: !viewModel.loading && viewModel.isValid))
                    .disabled(viewModel.loading || !viewModel.isValid)

                    Button("Cancel") {
                        viewModel.onBackSelected?()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.top, 8)

                Spacer(minLength: 24)
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

    private func amountChip(for amount: Int) -> some View {
        let isSelected = viewModel.selectedAmountCents == amount
        let isAllowed = amount <= viewModel.maxAllowed

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                viewModel.selectedAmountCents = amount
            }
        } label: {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(amount.rupiah)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            !isAllowed ? Palette.muted : (isSelected ? Palette.amberLight : Palette.ink)
                        )

                    Text(isAllowed ? "Instant Cash" : "Limit exceeded")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(
                            !isAllowed ? Palette.red.opacity(0.8) : (isSelected ? Palette.amber : Palette.muted)
                        )
                }

                Spacer()

                if !isAllowed {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(Palette.muted)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Palette.amber)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Palette.goldCardGradient : Palette.cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Palette.amber : Palette.border,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? Palette.amber.opacity(0.25) : Color.clear,
                radius: 8,
                x: 0,
                y: 2
            )
            .opacity(isAllowed ? 1.0 : 0.45)
        }
        .disabled(!isAllowed)
    }
}
