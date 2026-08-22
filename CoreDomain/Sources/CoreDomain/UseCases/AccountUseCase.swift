//
//  AccountUseCase.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public protocol AccountUseCase {
    func execute(email: String) async throws -> AccountEntity
}

public final class AccountUseCaseImpl: AccountUseCase {
    private let repository: TapCashRepository

    public init(repository: TapCashRepository) {
        self.repository = repository
    }

    public func execute(email: String) async throws -> AccountEntity {
        let account = try await repository.getAccount(email: email)
        return account
    }
}
