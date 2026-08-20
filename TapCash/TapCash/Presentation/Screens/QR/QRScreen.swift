//
//  QRScreen.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI
import Combine

struct QRScreen: View {
    @ObservedObject var viewModel: QRScreenViewModel
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            if let ticket = viewModel.ticket {
                let expired = viewModel.remainingSeconds <= 0
                Eyebrow(text: "Show this code at the ATM")
                Text(ticket.amountCents.rupiah)
                    .font(.system(size: 38, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink)

                ZStack {
                    if let image = QRCode.image(from: ticket.qrPayload) {
                        Image(uiImage: image)
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 240, height: 240)
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    if expired {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Palette.navy.opacity(0.94))
                            .frame(width: 272, height: 272)
                            .overlay(
                                VStack(spacing: 4) {
                                    Text("EXPIRED").foregroundStyle(.white).font(.headline).tracking(2)
                                    Text("Refreshing…").foregroundStyle(.white.opacity(0.8)).font(.caption)
                                }
                            )
                    }
                }

                Text(expired
                     ? "Codes expire for your safety — a fresh one is on the way."
                     : "Expires in \(timeString) · a new code refreshes automatically.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(expired ? .red : Palette.muted)

                Text("Txn \(ticket.transactionId.prefix(8))…")
                    .font(.footnote.monospaced())

                Spacer()
                
                Button("Refresh code now") {
                    viewModel.refreshTicket()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Done") {
                    viewModel.finish()
                }
                .font(.headline).foregroundStyle(Palette.navy)
                .frame(maxWidth: .infinity, minHeight: 52)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.navy, lineWidth: 1))
            }
        }
        .padding(24)
        .onAppear { viewModel.syncRemaining() }
        .onDisappear { viewModel.stopValidationPolling() }
        .onChange(of: viewModel.ticket?.token) { _ in viewModel.syncRemaining() }
        .onReceive(tick) { _ in
            viewModel.tick()
        }
    }

    private var timeString: String {
        String(format: "%02d:%02d", viewModel.remainingSeconds / 60, viewModel.remainingSeconds % 60)
    }
}
