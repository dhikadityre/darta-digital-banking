import Foundation
import SwiftUI
import Combine

/// Observable state for the whole withdrawal flow.
@MainActor
final class WithdrawalViewModel: ObservableObject {

    enum Route { case login, home, amount, qr, scan, result }

    @Published var route: Route = .login
    @Published var loading = false
    @Published var errorMessage: String?

    @Published var email: String?
    @Published var displayName: String?
    @Published var balanceCents: Int = 0
    @Published var limits: LimitsEntity?
    @Published var ticket: TicketEntity?
    @Published var lastAmountCents: Int = 0

    // ATM (scan & redeem) mode
    @Published var dispenseResult: DispenseEntity?
    @Published var scanError: String?

    private let loginUseCase: LoginUseCase
    private let getLimitsUseCase: GetLimitsUseCase
    private let createWithdrawalUseCase: CreateWithdrawalUseCase
    private let dispenseUseCase: DispenseUseCase

    init(
        loginUseCase: LoginUseCase?,
        getLimitsUseCase: GetLimitsUseCase?,
        createWithdrawalUseCase: CreateWithdrawalUseCase?,
        dispenseUseCase: DispenseUseCase?
    ) {
        self.loginUseCase = loginUseCase ?? LoginUseCaseImpl()
        self.getLimitsUseCase = getLimitsUseCase ?? GetLimitsUseCaseImpl()
        self.createWithdrawalUseCase = createWithdrawalUseCase ?? CreateWithdrawalUseCaseImpl()
        self.dispenseUseCase = dispenseUseCase ?? DispenseUseCaseImpl()
    }

    func login(email: String, password: String) {
        loading = true
        errorMessage = nil
        Task {
            do {
                let result = try await loginUseCase.execute(email: email, password: password)
                self.email = result.account.email
                self.displayName = result.account.displayName
                self.balanceCents = result.account.availableBalanceCents
                self.limits = result.limits
                self.loading = false
                self.route = .home
            } catch {
                self.loading = false
                self.errorMessage = "Login failed. Check demo credentials."
            }
        }
    }

    func refreshLimits() {
        guard let email else { return }
        Task { self.limits = try? await getLimitsUseCase.execute(email: email) }
    }

    func createWithdrawal(amountCents: Int) {
        guard let email else { return }
        loading = true
        errorMessage = nil
        lastAmountCents = amountCents
        Task {
            do {
                let ticket = try await createWithdrawalUseCase.execute(email: email, amountCents: amountCents)
                self.ticket = ticket
                self.loading = false
                self.route = .qr
            } catch let apiError as ApiErrorEntity {
                self.loading = false
                self.errorMessage = apiError.message
            } catch {
                self.loading = false
                self.errorMessage = "Could not create QR. Try again."
            }
        }
    }

    /// Silently mints a fresh ticket for the same amount when the current one expires.
    func refreshTicket() {
        guard let email, lastAmountCents > 0 else { return }
        Task {
            if let fresh = try? await createWithdrawalUseCase.execute(email: email, amountCents: lastAmountCents) {
                self.ticket = fresh
            }
        }
    }

    func startScan() {
        scanError = nil
        dispenseResult = nil
        route = .scan
    }

    func dispenseScanned(qrPayload: String) {
        guard !loading else { return }
        loading = true
        scanError = nil
        Task {
            do {
                let result = try await dispenseUseCase.execute(qrPayload: qrPayload)
                self.dispenseResult = result
                self.loading = false
                self.route = .result
            } catch {
                self.loading = false
                self.scanError = "Code rejected. It may be used, expired, or invalid."
            }
        }
    }

    func finish() {
        ticket = nil
        dispenseResult = nil
        scanError = nil
        route = .home
        refreshLimits()
    }
}
