import Foundation

protocol GetLimitsUseCase {
    func execute(email: String) async throws -> LimitsResponse
}

final class GetLimitsUseCaseImpl: GetLimitsUseCase {
    private let repository: TapCashRepository

    init(repository: TapCashRepository = TapCashRepositoryImpl()) {
        self.repository = repository
    }

    func execute(email: String) async throws -> LimitsResponse {
        try await repository.getLimits(email: email)
    }
}
