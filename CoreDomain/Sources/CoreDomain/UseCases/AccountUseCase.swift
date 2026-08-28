//
//  AccountUseCase.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public protocol AccountUseCase: Sendable {
    func execute(email: String) async throws -> AccountEntity
}

public final class AccountUseCaseImpl: AccountUseCase, @unchecked Sendable {
    private let repository: DartaRepository

    public init(repository: DartaRepository) {
        self.repository = repository
    }

    public func execute(email: String) async throws -> AccountEntity {
        let account = try await repository.getAccount(email: email)
        return account
    }
}
