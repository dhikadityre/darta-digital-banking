//
//  AccountUseCase.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public protocol LoginUseCase: Sendable {
    func execute(email: String, password: String) async throws -> (account: AccountEntity, limits: LimitsEntity)
}

public final class LoginUseCaseImpl: LoginUseCase, @unchecked Sendable {
    private let repository: DartaRepository

    public init(repository: DartaRepository) {
        self.repository = repository
    }

    public func execute(email: String, password: String) async throws -> (account: AccountEntity, limits: LimitsEntity) {
        let session = try await repository.login(email: email, password: password)
        let account = try await repository.getAccount(email: session.email)
        let limits = try await repository.getLimits(email: session.email)
        return (account, limits)
    }
}
