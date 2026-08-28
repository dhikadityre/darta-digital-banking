//
//  AccountUseCase.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public protocol GetLimitsUseCase: Sendable {
    func execute(email: String) async throws -> LimitsEntity
}

public final class GetLimitsUseCaseImpl: GetLimitsUseCase, @unchecked Sendable {
    private let repository: DartaRepository

    public init(repository: DartaRepository) {
        self.repository = repository
    }

    public func execute(email: String) async throws -> LimitsEntity {
        try await repository.getLimits(email: email)
    }
}
