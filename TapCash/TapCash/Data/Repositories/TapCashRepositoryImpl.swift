import Foundation

final class TapCashRepositoryImpl: TapCashRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        try await apiClient.login(email: email, password: password)
    }

    func getAccount(email: String) async throws -> AccountResponse {
        try await apiClient.account(email: email)
    }

    func getLimits(email: String) async throws -> LimitsResponse {
        try await apiClient.limits(email: email)
    }

    func createWithdrawal(email: String, amountCents: Int) async throws -> TicketResponse {
        try await apiClient.createWithdrawal(email: email, amountCents: amountCents)
    }

    func dispense(qrPayload: String) async throws -> DispenseResponse {
        try await apiClient.dispense(qrPayload: qrPayload)
    }
}
