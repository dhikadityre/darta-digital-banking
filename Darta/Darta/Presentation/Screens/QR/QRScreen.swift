//
//  QRScreen.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI
import Combine
import CoreDomain

struct QRScreen: View {
    @ObservedObject var viewModel: QRScreenViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                if let ticket = viewModel.ticket {
                    let expired = viewModel.remainingSeconds <= 0

                    // MARK: - Header
                    VStack(spacing: 8) {
                        EyebrowView(text: "Cashier Withdrawal", iconName: "qrcode")

                        Text(ticket.amountCents.rupiah)
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(Palette.ink)

                        Text("Present this QR code to the cashier for cash dispensation.")
                            .font(.footnote)
                            .foregroundStyle(Palette.inkSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)

                    // MARK: - QR Ticket Card
                    VStack(spacing: 18) {
                        ZStack {
                            // High Contrast QR Frame
                            if let image = QRCode.image(from: ticket.qrPayload) {
                                Image(uiImage: image)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 220, height: 220)
                                    .padding(16)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Palette.amber.opacity(0.4), lineWidth: 2)
                                    )
                            }

                            // Expired Overlay
                            if expired {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Palette.canvas.opacity(0.92))
                                    .frame(width: 252, height: 252)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "clock.badge.xmark.fill")
                                                .font(.system(size: 36))
                                                .foregroundStyle(Palette.red)

                                            Text("CODE EXPIRED")
                                                .font(.headline.weight(.bold))
                                                .tracking(2)
                                                .foregroundStyle(Palette.ink)

                                            Text("Refreshing fresh ticket…")
                                                .font(.caption)
                                                .foregroundStyle(Palette.muted)
                                        }
                                    )
                            }
                        }

                        // Countdown Timer Pill
                        HStack(spacing: 8) {
                            Image(systemName: expired ? "exclamationmark.circle.fill" : "timer")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(expired ? Palette.red : Palette.amber)

                            Text(expired ? "Ticket expired" : "Valid for \(timeString)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(expired ? Palette.red : Palette.ink)

                            if !expired {
                                Circle()
                                    .fill(Palette.amber)
                                    .frame(width: 4, height: 4)

                                Text("Auto-refresh")
                                    .font(.caption)
                                    .foregroundStyle(Palette.muted)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(expired ? Palette.red.opacity(0.12) : Palette.surfaceElevated)
                        )
                        .overlay(
                            Capsule()
                                .stroke(expired ? Palette.red.opacity(0.3) : Palette.border, lineWidth: 1)
                        )

                        // Transaction ID
                        HStack(spacing: 6) {
                            Text("Transaction ID:")
                                .font(.caption2)
                                .foregroundStyle(Palette.muted)

                            Text(ticket.transactionId.prefix(12) + "…")
                                .font(.caption2.monospaced())
                                .foregroundStyle(Palette.inkSecondary)
                        }
                    }
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Palette.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Palette.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 15, x: 0, y: 8)

                    // MARK: - Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            viewModel.refreshTicket()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.headline.weight(.bold))
                                Text("Refresh Code Now")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button("Done") {
                            viewModel.finish()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(.top, 4)

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
        .onAppear { viewModel.syncRemaining() }
        .onDisappear { viewModel.stopValidationPolling() }
        .onChange(of: viewModel.ticket?.token) { _ in viewModel.syncRemaining() }
    }

    private var timeString: String {
        String(format: "%02d:%02d", viewModel.remainingSeconds / 60, viewModel.remainingSeconds % 60)
    }
}
