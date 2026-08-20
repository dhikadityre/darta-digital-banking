//
//  AccountUseCase.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

protocol AccountUseCase {
    func execute(email: String) async throws -> AccountEntity
}

final class AccountUseCaseImpl: AccountUseCase {
    private let repository: TapCashRepository

    init(repository: TapCashRepository) {
        self.repository = repository
    }

    func execute(email: String) async throws -> AccountEntity {
        let account = try await repository.getAccount(email: email)
        return account
    }
}
