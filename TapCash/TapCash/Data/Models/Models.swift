import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let email: String
    let displayName: String
    let token: String
}

struct AccountResponse: Decodable {
    let email: String
    let displayName: String
    let availableBalanceCents: Int
    let currency: String
    let simulated: Bool
}

struct LimitsResponse: Decodable {
    let minCents: Int
    let maxCents: Int
    let stepCents: Int
    let dailyLimitCents: Int
    let withdrawnTodayCents: Int
    let remainingTodayCents: Int
    let qrTtlSeconds: Int
    let currency: String
    let simulated: Bool
}

struct CreateWithdrawalRequest: Encodable {
    let email: String
    let amountCents: Int
}

struct CreateWithdrawalValidateRequest: Encodable {
    let qrPayload: String
    let token: String
}

struct CreateWithdrawalValidateResponse: Codable {
    let token: String
    let qrPayload: String
    let amountCents: Int
    let expiresAt: String
    let transactionId: String
    let used: Bool
    let status: String
    let simulated: Bool
}

struct TicketResponse: Decodable, Identifiable {
    let token: String
    let qrPayload: String
    let amountCents: Int
    let expiresAt: String
    let transactionId: String
    let used: Bool
    let status: String
    let simulated: Bool

    var id: String { token }
}

struct RedeemRequest: Encodable {
    let qrPayload: String
}

struct DispenseResponse: Decodable {
    let status: String
    let amountCents: Int
    let transactionId: String
    let remainingBalanceCents: Int
    let dispensedAt: String
    let simulated: Bool
}

struct ApiError: Decodable, Error {
    let status: Int
    let error: String
    let message: String
}


