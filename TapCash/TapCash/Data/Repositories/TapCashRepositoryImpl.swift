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

    func login(email: String, password: String) async throws -> LoginEntity {
        let url = baseURL.appendingPathComponent("/api/auth/login")
        let requestBody = LoginRequest(email: email.lowercased(), password: password)
        let bodyData = try encoder.encode(requestBody)
        let (data, response) = try await client.post(to: url, data: bodyData)
        do {
            let dto: LoginResponse = try RemoteMapper.map(data, response, decoder: decoder)
            return dto.toEntity()
        } catch let apiError as ApiError {
            throw apiError.toEntity()
        }
    }

    func getAccount(email: String) async throws -> AccountEntity {
        let url = baseURL.appendingPathComponent("/api/accounts/\(email.lowercased())")
        let (data, response) = try await client.get(from: url)
        do {
            let dto: AccountResponse = try RemoteMapper.map(data, response, decoder: decoder)
            return dto.toEntity()
        } catch let apiError as ApiError {
            throw apiError.toEntity()
        }
    }

    func getLimits(email: String) async throws -> LimitsEntity {
        let url = baseURL.appendingPathComponent("/api/accounts/\(email.lowercased())/limits")
        let (data, response) = try await client.get(from: url)
        do {
            let dto: LimitsResponse = try RemoteMapper.map(data, response, decoder: decoder)
            return dto.toEntity()
        } catch let apiError as ApiError {
            throw apiError.toEntity()
        }
    }

    func createWithdrawal(email: String, amountCents: Int) async throws -> TicketEntity {
        let url = baseURL.appendingPathComponent("/api/withdrawals")
        let requestBody = CreateWithdrawalRequest(email: email.lowercased(), amountCents: amountCents)
        let bodyData = try encoder.encode(requestBody)
        let (data, response) = try await client.post(to: url, data: bodyData)
        do {
            let dto: TicketResponse = try RemoteMapper.map(data, response, decoder: decoder)
            return dto.toEntity()
        } catch let apiError as ApiError {
            throw apiError.toEntity()
        }
    }

    func dispense(qrPayload: String) async throws -> DispenseEntity {
        let url = baseURL.appendingPathComponent("/api/withdrawals/dispense")
        let requestBody = RedeemRequest(qrPayload: qrPayload)
        let bodyData = try encoder.encode(requestBody)
        let (data, response) = try await client.post(to: url, data: bodyData)
        do {
            let dto: DispenseResponse = try RemoteMapper.map(data, response, decoder: decoder)
            return dto.toEntity()
        } catch let apiError as ApiError {
            throw apiError.toEntity()
        }
    }
}

// MARK: - DTO to Entity Mappings

extension LoginResponse {
    func toEntity() -> LoginEntity {
        LoginEntity(email: email, displayName: displayName, token: token)
    }
}

extension AccountResponse {
    func toEntity() -> AccountEntity {
        AccountEntity(
            email: email,
            displayName: displayName,
            availableBalanceCents: availableBalanceCents,
            currency: currency,
            simulated: simulated
        )
    }
}

extension LimitsResponse {
    func toEntity() -> LimitsEntity {
        LimitsEntity(
            minCents: minCents,
            maxCents: maxCents,
            stepCents: stepCents,
            dailyLimitCents: dailyLimitCents,
            withdrawnTodayCents: withdrawnTodayCents,
            remainingTodayCents: remainingTodayCents,
            qrTtlSeconds: qrTtlSeconds,
            currency: currency,
            simulated: simulated
        )
    }
}

extension TicketResponse {
    func toEntity() -> TicketEntity {
        TicketEntity(
            token: token,
            qrPayload: qrPayload,
            amountCents: amountCents,
            expiresAt: expiresAt,
            transactionId: transactionId,
            used: used,
            status: status,
            simulated: simulated
        )
    }
}

extension DispenseResponse {
    func toEntity() -> DispenseEntity {
        DispenseEntity(
            status: status,
            amountCents: amountCents,
            transactionId: transactionId,
            remainingBalanceCents: remainingBalanceCents,
            dispensedAt: dispensedAt,
            simulated: simulated
        )
    }
}

extension ApiError {
    func toEntity() -> ApiErrorEntity {
        ApiErrorEntity(status: status, error: error, message: message)
    }
}
