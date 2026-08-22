//
//  AccountUseCase.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import CoreDomain

protocol DispenseUseCase {
    func execute(qrPayload: String) async throws -> DispenseEntity
}

final class DispenseUseCaseImpl: DispenseUseCase {
    private let repository: TapCashRepository

    init(repository: TapCashRepository) {
        self.repository = repository
    }

    func execute(qrPayload: String) async throws -> DispenseEntity {
        try await repository.dispense(qrPayload: qrPayload)
    }
}
