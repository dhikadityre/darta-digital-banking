import Foundation

/// Networking layer for the TapCash Spring Boot API using async/await URLSession.
struct APIClient {

    /// Base URL of the backend. Use your Mac's LAN IP when running on a physical device.
    /// The iOS Simulator can reach the host via `http://localhost:8080`.
    // static let baseURL = URL(string: "http://localhost:8080")!
    static let baseURL = Config.apiBaseUrl!

    private let session: URLSession = .shared
    private let decoder: JSONDecoder = JSONDecoder()
    private let encoder: JSONEncoder = JSONEncoder()

    func login(email: String, password: String) async throws -> LoginResponse {
        try await post("/api/auth/login", body: LoginRequest(email: email.lowercased(), password: password))
    }

    func account(email: String) async throws -> AccountResponse {
        try await get("/api/accounts/\(email.lowercased())")
    }

    func limits(email: String) async throws -> LimitsResponse {
        try await get("/api/accounts/\(email.lowercased())/limits")
    }

    func createWithdrawal(email: String, amountCents: Int) async throws -> TicketResponse {
        try await post("/api/withdrawals",
                       body: CreateWithdrawalRequest(email: email.lowercased(), amountCents: amountCents))
    }

    func dispense(qrPayload: String) async throws -> DispenseResponse {
        try await post("/api/withdrawals/dispense", body: RedeemRequest(qrPayload: qrPayload))
    }

    // MARK: - transport

    private func get<T: Decodable>(_ path: String) async throws -> T {
        var request = URLRequest(url: Self.baseURL.appendingPathComponent(path))
        request.httpMethod = "GET"
        return try await send(request)
    }

    private func post<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        var request = URLRequest(url: Self.baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return try await send(request)
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            if let apiError = try? decoder.decode(ApiError.self, from: data) {
                throw apiError
            }
            throw URLError(.init(rawValue: http.statusCode))
        }
        return try decoder.decode(T.self, from: data)
    }
}
