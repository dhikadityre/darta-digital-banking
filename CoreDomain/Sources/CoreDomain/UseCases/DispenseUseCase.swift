//
//  AccountUseCase.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public protocol DispenseUseCase {
    func execute(qrPayload: String) async throws -> DispenseEntity
}

public final class DispenseUseCaseImpl: DispenseUseCase {
    private let repository: TapCashRepository

    public init(repository: TapCashRepository) {
        self.repository = repository
    }

    public func execute(qrPayload: String) async throws -> DispenseEntity {
        try await repository.dispense(qrPayload: qrPayload)
    }
}
