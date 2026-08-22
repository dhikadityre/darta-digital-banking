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
    private let appConfig: AppConfig
    private let loginUseCase: LoginUseCase
    private let getLimitsUseCase: GetLimitsUseCase
    private let accountUseCase: AccountUseCase
    private let createWithdrawalUseCase: CreateWithdrawalUseCase
    private let dispenseUseCase: DispenseUseCase

    init() {
        let config = DefaultAppConfig()
        self.appConfig = config
        let repository = TapCashRepositoryImpl(
            client: URLSessionHTTPClient(),
            baseURL: config.apiBaseUrl!
        )
        self.loginUseCase = LoginUseCaseImpl(repository: repository)
        self.getLimitsUseCase = GetLimitsUseCaseImpl(repository: repository)
        self.accountUseCase = AccountUseCaseImpl(repository: repository)
        self.createWithdrawalUseCase = CreateWithdrawalUseCaseImpl(repository: repository)
        self.dispenseUseCase = DispenseUseCaseImpl(repository: repository)
    }
    
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
        .adaptiveStatusBar(backgroundColor: Palette.canvas)
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
            balanceCents: router.sessionBalanceCents,
            appConfig: appConfig
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
            createWithdrawalUseCase: createWithdrawalUseCase,
            appConfig: appConfig
        )
        vm.onFinished = {
            Task {
                if let email = router.sessionEmail {
                    async let limits = try? getLimitsUseCase.execute(email: email)
                    async let account = try? accountUseCase.execute(email: email)
                    let (resolvedLimits, resolvedAccount) = await (limits, account)
                    
                    router.navigateToHome(
                        email: email,
                        displayName: resolvedAccount?.displayName ?? (router.sessionDisplayName ?? ""),
                        balanceCents: resolvedAccount?.availableBalanceCents ?? router.sessionBalanceCents,
                        limits: resolvedLimits
                    )
                } else {
                    router.navigateToLogin()
                }
            }
        }
        vm.onWithdrawalUsed = { validateEntity in
            let dispenseResult = DispenseEntity(
                status: validateEntity.status,
                amountCents: validateEntity.amountCents,
                transactionId: validateEntity.transactionId,
                remainingBalanceCents: router.sessionBalanceCents - validateEntity.amountCents,
                dispensedAt: validateEntity.expiresAt,
                simulated: validateEntity.simulated
            )
            router.navigateToResult(result: dispenseResult)
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
                    async let limits = try? getLimitsUseCase.execute(email: email)
                    async let account = try? accountUseCase.execute(email: email)
                    let (resolvedLimits, resolvedAccount) = await (limits, account)
                    
                    router.navigateToHome(
                        email: email,
                        displayName: resolvedAccount?.displayName ?? (router.sessionDisplayName ?? ""),
                        balanceCents: resolvedAccount?.availableBalanceCents ?? router.sessionBalanceCents,
                        limits: resolvedLimits
                    )
                } else {
                    router.navigateToLogin()
                }
            }
        }
        return vm
    }
}
