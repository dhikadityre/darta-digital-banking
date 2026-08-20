//
//  RootView.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = NavigationRouter()
    
    // Dependencies
    private let loginUseCase: LoginUseCase = LoginUseCaseImpl()
    private let getLimitsUseCase: GetLimitsUseCase = GetLimitsUseCaseImpl()
    private let createWithdrawalUseCase: CreateWithdrawalUseCase = CreateWithdrawalUseCaseImpl()
    private let dispenseUseCase: DispenseUseCase = DispenseUseCaseImpl()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                Palette.canvas.ignoresSafeArea()
                LoginScreen(viewModel: makeLoginViewModel())
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: NavigationRouter.Route.self) { route in
                ZStack {
                    Palette.canvas.ignoresSafeArea()
                    switch route {
                    case .login:
                        LoginScreen(viewModel: makeLoginViewModel())
                    case .home:
                        HomeScreen(viewModel: makeHomeViewModel())
                    case .amount:
                        AmountScreen(viewModel: makeAmountViewModel())
                    case .qr:
                        QRScreen(viewModel: makeQRViewModel())
                    case .scan:
                        ScanScreen(viewModel: makeScanViewModel())
                    case .result:
                        ResultScreen(viewModel: makeResultViewModel())
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

// MARK: - Factory Methods
extension RootView {
    private func makeLoginViewModel() -> LoginScreenViewModel {
        let vm = LoginScreenViewModel(loginUseCase: loginUseCase)
        vm.onLoginSuccess = { email, displayName, balanceCents, limits in
            router.navigateToHome(
                email: email,
                displayName: displayName,
                balanceCents: balanceCents,
                limits: limits
            )
        }
        return vm
    }
    
    private func makeHomeViewModel() -> HomeScreenViewModel {
        let vm = HomeScreenViewModel(
            displayName: router.sessionDisplayName ?? "",
            balanceCents: router.sessionBalanceCents
        )
        vm.onWithdrawSelected = {
            router.navigateToAmount()
        }
        vm.onScanSelected = {
            router.navigateToScan()
        }
        return vm
    }
    
    private func makeAmountViewModel() -> AmountScreenViewModel {
        let vm = AmountScreenViewModel(
            limits: router.sessionLimits,
            email: router.sessionEmail ?? "",
            createWithdrawalUseCase: createWithdrawalUseCase
        )
        vm.onTicketCreated = { ticket, amountCents in
            router.navigateToQR(ticket: ticket, amountCents: amountCents)
        }
        vm.onBackSelected = {
            router.navigateToHome(
                email: router.sessionEmail ?? "",
                displayName: router.sessionDisplayName ?? "",
                balanceCents: router.sessionBalanceCents,
                limits: router.sessionLimits
            )
        }
        return vm
    }
    
    private func makeQRViewModel() -> QRScreenViewModel {
        let vm = QRScreenViewModel(
            ticket: router.sessionTicket,
            email: router.sessionEmail ?? "",
            amountCents: router.sessionLastAmountCents,
            createWithdrawalUseCase: createWithdrawalUseCase
        )
        vm.onFinished = {
            Task {
                if let email = router.sessionEmail {
                    let limits = try? await getLimitsUseCase.execute(email: email)
                    router.navigateToHome(
                        email: email,
                        displayName: router.sessionDisplayName ?? "",
                        balanceCents: router.sessionBalanceCents,
                        limits: limits
                    )
                } else {
                    router.navigateToLogin()
                }
            }
        }
        return vm
    }
    
    private func makeScanViewModel() -> ScanScreenViewModel {
        let vm = ScanScreenViewModel(dispenseUseCase: dispenseUseCase)
        vm.onDispenseCompleted = { result in
            router.navigateToResult(result: result)
        }
        vm.onCancelled = {
            router.navigateToHome(
                email: router.sessionEmail ?? "",
                displayName: router.sessionDisplayName ?? "",
                balanceCents: router.sessionBalanceCents,
                limits: router.sessionLimits
            )
        }
        return vm
    }
    
    private func makeResultViewModel() -> ResultScreenViewModel {
        let vm = ResultScreenViewModel(dispenseResult: router.sessionDispenseResult)
        vm.onDone = {
            if let result = router.sessionDispenseResult {
                router.sessionBalanceCents = result.remainingBalanceCents
            }
            Task {
                if let email = router.sessionEmail {
                    let limits = try? await getLimitsUseCase.execute(email: email)
                    router.navigateToHome(
                        email: email,
                        displayName: router.sessionDisplayName ?? "",
                        balanceCents: router.sessionBalanceCents,
                        limits: limits
                    )
                } else {
                    router.navigateToLogin()
                }
            }
        }
        return vm
    }
}
