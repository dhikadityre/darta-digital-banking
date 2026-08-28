import Foundation

public protocol DartaRepository: Sendable {
    func login(email: String, password: String) async throws -> LoginEntity
    func getAccount(email: String) async throws -> AccountEntity
    func getLimits(email: String) async throws -> LimitsEntity
    func createWithdrawal(email: String, amountCents: Int) async throws -> TicketEntity
    func createValidateWithdrawal(qrPayload: String) async throws -> WithdrawalValidateEntity
    func dispense(qrPayload: String) async throws -> DispenseEntity
}
