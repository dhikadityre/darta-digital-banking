//
//  AccountUseCase.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public protocol DispenseUseCase: Sendable {
    func execute(qrPayload: String) async throws -> DispenseEntity
}

public final class DispenseUseCaseImpl: DispenseUseCase, @unchecked Sendable {
    private let repository: DartaRepository

    public init(repository: DartaRepository) {
        self.repository = repository
    }

    public func execute(qrPayload: String) async throws -> DispenseEntity {
        try await repository.dispense(qrPayload: qrPayload)
    }
}
