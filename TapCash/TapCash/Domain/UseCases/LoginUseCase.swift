//
//  AccountUseCase.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

protocol LoginUseCase {
    func execute(email: String, password: String) async throws -> (account: AccountEntity, limits: LimitsEntity)
}

final class LoginUseCaseImpl: LoginUseCase {
    private let repository: TapCashRepository

    init(repository: TapCashRepository) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws -> (account: AccountEntity, limits: LimitsEntity) {
        let session = try await repository.login(email: email, password: password)
        let account = try await repository.getAccount(email: session.email)
        let limits = try await repository.getLimits(email: session.email)
        return (account, limits)
    }
}
