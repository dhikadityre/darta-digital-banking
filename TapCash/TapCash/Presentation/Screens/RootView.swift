//
//  RootView.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import SwiftUI

struct RootView: View {
    @StateObject private var vm = WithdrawalViewModel(
        loginUseCase: LoginUseCaseImpl(),
        getLimitsUseCase: GetLimitsUseCaseImpl(),
        createWithdrawalUseCase: CreateWithdrawalUseCaseImpl(),
        dispenseUseCase: DispenseUseCaseImpl()
    )

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()
            switch vm.route {
            case .login:  LoginView(vm: vm)
            case .home:   HomeView(vm: vm)
            case .amount: AmountView(vm: vm)
            case .qr:     QRView(vm: vm)
            case .scan:   ScanView(vm: vm)
            case .result: ResultView(vm: vm)
            }
        }
        .animation(.easeInOut, value: vm.route)
    }
}
