//
//  AccountUseCase.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public protocol CreateWithdrawalUseCase {
    func execute(email: String, amountCents: Int) async throws -> TicketEntity
    func validate(qrPayload: String) async throws -> WithdrawalValidateEntity
}

public final class CreateWithdrawalUseCaseImpl: CreateWithdrawalUseCase {
    private let repository: TapCashRepository

    public init(repository: TapCashRepository) {
        self.repository = repository
    }

    public func execute(email: String, amountCents: Int) async throws -> TicketEntity {
        try await repository.createWithdrawal(email: email, amountCents: amountCents)
    }
    
    public func validate(qrPayload: String) async throws -> WithdrawalValidateEntity {
        try await repository.createValidateWithdrawal(qrPayload: qrPayload)
    }
}
