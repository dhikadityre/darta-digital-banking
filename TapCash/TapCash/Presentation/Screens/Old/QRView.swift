////
////  QRView.swift
////  TapCash
////
////  Created by DHIKA ADITYA ARE on 19/08/26.
////
//
//import SwiftUI
//import Combine
//
//struct QRView: View {
//    @ObservedObject var vm: WithdrawalViewModel
//    @State private var remaining = 0
//    @State private var refreshed = false
//    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//
//    private static func secondsUntil(_ iso: String) -> Int {
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
//        guard let date else { return 0 }
//        return max(0, Int(date.timeIntervalSinceNow))
//    }
//
//    var body: some View {
//        VStack(spacing: 16) {
//            if let ticket = vm.ticket {
//                let expired = remaining <= 0
//                Eyebrow(text: "Show this code at the Cashier")
//                Text(ticket.amountCents.usd)
//                    .font(.system(size: 38, weight: .bold, design: .monospaced))
//                    .foregroundStyle(Palette.ink)
//
//                ZStack {
//                    if let image = QRCode.image(from: ticket.qrPayload) {
//                        Image(uiImage: image)
//                            .interpolation(.none)
//                            .resizable()
//                            .frame(width: 240, height: 240)
//                            .padding(16)
//                            .background(Color.white)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                    }
//                    if expired {
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Palette.navy.opacity(0.94))
//                            .frame(width: 272, height: 272)
//                            .overlay(
//                                VStack(spacing: 4) {
//                                    Text("EXPIRED").foregroundStyle(.white).font(.headline).tracking(2)
//                                    Text("Refreshing…").foregroundStyle(.white.opacity(0.8)).font(.caption)
//                                }
//                            )
//                    }
//                }
//
//                Text(expired
//                     ? "Codes expire for your safety — a fresh one is on the way."
//                     : "Expires in \(timeString) · a new code refreshes automatically.")
//                    .multilineTextAlignment(.center)
//                    .foregroundStyle(expired ? .red : Palette.muted)
//
//                Text("Txn \(ticket.transactionId.prefix(8))…")
//                    .font(.footnote.monospaced())
//
//                Spacer()
//                Button("Refresh code now") { vm.refreshTicket() }
//                    .buttonStyle(PrimaryButtonStyle())
//                Button("Done") { vm.finish() }
//                    .font(.headline).foregroundStyle(Palette.navy)
//                    .frame(maxWidth: .infinity, minHeight: 52)
//                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.navy, lineWidth: 1))
//            }
//        }
//        .padding(24)
//        .onAppear { syncRemaining() }
//        .onChange(of: vm.ticket?.token) { _ in refreshed = false; syncRemaining() }
//        .onReceive(tick) { _ in
//            syncRemaining()
//            if remaining <= 0 && !refreshed {
//                refreshed = true
//                vm.refreshTicket()
//            }
//        }
//    }
//
//    private var timeString: String {
//        String(format: "%02d:%02d", remaining / 60, remaining % 60)
//    }
//
//    private func syncRemaining() {
//        if let iso = vm.ticket?.expiresAt { remaining = Self.secondsUntil(iso) }
//    }
//}
