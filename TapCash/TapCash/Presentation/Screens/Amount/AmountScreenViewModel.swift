//
//  AmountScreenViewModel.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import Combine
import CoreDomain

@MainActor
final class AmountScreenViewModel: ObservableObject {
    @Published var selectedAmountCents = 20_000
    @Published var loading = false
    @Published var errorMessage: String?
    
    let options = [
        10_000,
        20_000,
        50_000,
        100_000,
        200_000
    ]
    
    let limits: LimitsEntity?
    private let email: String
    private let createWithdrawalUseCase: CreateWithdrawalUseCase
    
    var onTicketCreated: ((TicketEntity, Int) -> Void)?
    var onBackSelected: (() -> Void)?
    
    var maxAllowed: Int {
        min(
            limits?.maxCents
                ?? 200_000,
            limits?.remainingTodayCents
                ?? .max
        )
    }
    
    var minAllowed: Int {
        limits?.minCents ?? 10_000
    }
    
    var isValid: Bool {
        selectedAmountCents >= minAllowed && selectedAmountCents <= maxAllowed
    }
    
    init(
        limits: LimitsEntity?,
        email: String,
        createWithdrawalUseCase: CreateWithdrawalUseCase
    ) {
        self.limits = limits
        self.email = email
        self.createWithdrawalUseCase = createWithdrawalUseCase
    }
    
    func createWithdrawal() {
        guard !email.isEmpty, isValid else { return }
        loading = true
        errorMessage = nil
        Task {
            do {
                let ticket = try await createWithdrawalUseCase.execute(email: self.email, amountCents: self.selectedAmountCents)
                self.loading = false
                self.onTicketCreated?(ticket, self.selectedAmountCents)
            } catch let apiError as ApiErrorEntity {
                self.loading = false
                self.errorMessage = apiError.message
            } catch {
                self.loading = false
                self.errorMessage = "Could not create QR. Try again."
            }
        }
    }
}
