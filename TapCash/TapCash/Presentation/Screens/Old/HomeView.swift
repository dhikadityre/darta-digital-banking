////
////  HomeView.swift
////  TapCash
////
////  Created by DHIKA ADITYA ARE on 19/08/26.
////
//
//import SwiftUI
//
//struct HomeView: View {
//    @ObservedObject var vm: WithdrawalViewModel
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Eyebrow(text: "Available balance")
//            Text(vm.balanceCents.usd)
//                .font(.system(size: 44, weight: .bold, design: .rounded))
//                .foregroundStyle(Palette.ink)
//            Text("Welcome back, \(vm.displayName ?? "there").")
//                .foregroundStyle(Palette.muted)
//            Spacer()
//            Button("Withdraw cash") { vm.route = .amount }
//                .buttonStyle(PrimaryButtonStyle())
//            Button("Scan a code (Cashier mode)") { vm.startScan() }
//                .font(.headline)
//                .foregroundStyle(Palette.navy)
//                .frame(maxWidth: .infinity, minHeight: 52)
//                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.navy, lineWidth: 1))
//            Text("All funds are SIMULATED.")
//                .font(.footnote).foregroundStyle(Palette.muted)
//        }
//        .padding(24)
//    }
//}
