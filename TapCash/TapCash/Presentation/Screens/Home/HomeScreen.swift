//
//  HomeScreen.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeScreenViewModel
    
    var body: some View { render() }
    
    private func render() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            renderHeader()
            Spacer()
            renderContainerButton()
            renderInfo()
        }
        .padding(24)
    }
}

extension HomeScreen {
    private func renderHeader() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            EyebrowView(text: "Available balance")
            Text(viewModel.balanceCents.rupiah)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.ink)
            Text("Welcome back, \(viewModel.displayName).")
                .foregroundStyle(Palette.muted)
        }
    }
    
    private func renderContainerButton() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Button("Withdraw cash") {
                viewModel.onWithdrawSelected?()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("Scan a code (Cashier mode)") {
                viewModel.onScanSelected?()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
    
    private func renderInfo() -> some View {
        Text("All funds are SIMULATED.")
            .font(.footnote)
            .foregroundStyle(Palette.muted)
    }
}
