import Foundation

final class TapCashRepositoryImpl: TapCashRepository {
    private let client: HTTPClient
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(client: HTTPClient = URLSessionHTTPClient(),
         baseURL: URL = Config.apiBaseUrl!,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        self.client = client
        self.baseURL = baseURL
        self.decoder = decoder
        self.encoder = encoder
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        let url = baseURL.appendingPathComponent("/api/auth/login")
        let requestBody = LoginRequest(email: email.lowercased(), password: password)
        let bodyData = try encoder.encode(requestBody)
        let (data, response) = try await client.post(to: url, data: bodyData)
        return try RemoteMapper.map(data, response, decoder: decoder)
    }

    func getAccount(email: String) async throws -> AccountResponse {
        let url = baseURL.appendingPathComponent("/api/accounts/\(email.lowercased())")
        let (data, response) = try await client.get(from: url)
        return try RemoteMapper.map(data, response, decoder: decoder)
    }

    func getLimits(email: String) async throws -> LimitsResponse {
        let url = baseURL.appendingPathComponent("/api/accounts/\(email.lowercased())/limits")
        let (data, response) = try await client.get(from: url)
        return try RemoteMapper.map(data, response, decoder: decoder)
    }

    func createWithdrawal(email: String, amountCents: Int) async throws -> TicketResponse {
        let url = baseURL.appendingPathComponent("/api/withdrawals")
        let requestBody = CreateWithdrawalRequest(email: email.lowercased(), amountCents: amountCents)
        let bodyData = try encoder.encode(requestBody)
        let (data, response) = try await client.post(to: url, data: bodyData)
        return try RemoteMapper.map(data, response, decoder: decoder)
    }

    func dispense(qrPayload: String) async throws -> DispenseResponse {
        let url = baseURL.appendingPathComponent("/api/withdrawals/dispense")
        let requestBody = RedeemRequest(qrPayload: qrPayload)
        let bodyData = try encoder.encode(requestBody)
        let (data, response) = try await client.post(to: url, data: bodyData)
        return try RemoteMapper.map(data, response, decoder: decoder)
    }
}
