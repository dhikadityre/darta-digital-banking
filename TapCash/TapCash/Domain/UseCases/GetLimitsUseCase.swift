//
//  AccountUseCase.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

protocol GetLimitsUseCase {
    func execute(email: String) async throws -> LimitsEntity
}

final class GetLimitsUseCaseImpl: GetLimitsUseCase {
    private let repository: TapCashRepository

    init(repository: TapCashRepository = TapCashRepositoryImpl()) {
        self.repository = repository
    }

    func execute(email: String) async throws -> LimitsEntity {
        try await repository.getLimits(email: email)
    }
}
