import Foundation

protocol LoginUseCase {
    func execute(email: String, password: String) async throws -> (account: AccountResponse, limits: LimitsResponse)
}

final class LoginUseCaseImpl: LoginUseCase {
    private let repository: TapCashRepository

    init(repository: TapCashRepository = TapCashRepositoryImpl()) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws -> (account: AccountResponse, limits: LimitsResponse) {
        let session = try await repository.login(email: email, password: password)
        let account = try await repository.getAccount(email: session.email)
        let limits = try await repository.getLimits(email: session.email)
        return (account, limits)
    }
}
