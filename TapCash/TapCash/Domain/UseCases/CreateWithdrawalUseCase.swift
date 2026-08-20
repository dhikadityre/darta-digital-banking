import Foundation

protocol CreateWithdrawalUseCase {
    func execute(email: String, amountCents: Int) async throws -> TicketResponse
}

final class CreateWithdrawalUseCaseImpl: CreateWithdrawalUseCase {
    private let repository: TapCashRepository

    init(repository: TapCashRepository = TapCashRepositoryImpl()) {
        self.repository = repository
    }

    func execute(email: String, amountCents: Int) async throws -> TicketResponse {
        try await repository.createWithdrawal(email: email, amountCents: amountCents)
    }
}
