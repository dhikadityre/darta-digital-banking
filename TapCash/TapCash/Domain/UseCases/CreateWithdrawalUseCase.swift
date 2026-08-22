//
//  AccountUseCase.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import CoreDomain

protocol CreateWithdrawalUseCase {
    func execute(email: String, amountCents: Int) async throws -> TicketEntity
    func validate(qrPayload: String) async throws -> WithdrawalValidateEntity
}

final class CreateWithdrawalUseCaseImpl: CreateWithdrawalUseCase {
    private let repository: TapCashRepository

    init(repository: TapCashRepository) {
        self.repository = repository
    }

    func execute(email: String, amountCents: Int) async throws -> TicketEntity {
        try await repository.createWithdrawal(email: email, amountCents: amountCents)
    }
    
    func validate(qrPayload: String) async throws -> WithdrawalValidateEntity {
        try await repository.createValidateWithdrawal(qrPayload: qrPayload)
    }
}
