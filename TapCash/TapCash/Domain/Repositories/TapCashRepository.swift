import Foundation

protocol TapCashRepository {
    func login(email: String, password: String) async throws -> LoginEntity
    func getAccount(email: String) async throws -> AccountEntity
    func getLimits(email: String) async throws -> LimitsEntity
    func createWithdrawal(email: String, amountCents: Int) async throws -> TicketEntity
    func dispense(qrPayload: String) async throws -> DispenseEntity
}
