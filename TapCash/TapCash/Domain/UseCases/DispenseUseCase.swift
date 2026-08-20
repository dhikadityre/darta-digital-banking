import Foundation

protocol DispenseUseCase {
    func execute(qrPayload: String) async throws -> DispenseEntity
}

final class DispenseUseCaseImpl: DispenseUseCase {
    private let repository: TapCashRepository

    init(repository: TapCashRepository = TapCashRepositoryImpl()) {
        self.repository = repository
    }

    func execute(qrPayload: String) async throws -> DispenseEntity {
        try await repository.dispense(qrPayload: qrPayload)
    }
}
