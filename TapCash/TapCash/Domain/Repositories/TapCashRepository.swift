import Foundation

protocol TapCashRepository {
    func login(email: String, password: String) async throws -> LoginResponse
    func getAccount(email: String) async throws -> AccountResponse
    func getLimits(email: String) async throws -> LimitsResponse
    func createWithdrawal(email: String, amountCents: Int) async throws -> TicketResponse
    func dispense(qrPayload: String) async throws -> DispenseResponse
}
