//import Foundation
//
//final class DartaRepositoryImpl: DartaRepository {
//    private var authHeaders: [String: String]? {
//        guard let token = TokenManager.shared.token else { return nil }
//        return ["Authorization": "Bearer \(token)"]
//    }
//
//    private let client: HTTPClient
//    private let baseURL: URL
//    private let decoder: JSONDecoder
//    private let encoder: JSONEncoder
//
//    init(client: HTTPClient,
//         baseURL: URL,
//         decoder: JSONDecoder = JSONDecoder(),
//         encoder: JSONEncoder = JSONEncoder()) {
//        self.client = client
//        self.baseURL = baseURL
//        self.decoder = decoder
//        self.encoder = encoder
//    }
//
//    func login(email: String, password: String) async throws -> LoginEntity {
//        let url = baseURL.appendingPathComponent("/api/auth/login")
//        let requestBody = LoginRequest(email: email.lowercased(), password: password)
//        let bodyData = try encoder.encode(requestBody)
//        let (data, response) = try await client.post(to: url, data: bodyData)
//        do {
//            let dto: LoginResponse = try RemoteMapper.map(data, response, decoder: decoder)
//            let entity = dto.toEntity()
//            TokenManager.shared.token = entity.token
//            TokenManager.shared.refreshToken = dto.refreshToken
//            return entity
//        } catch let apiError as ApiError {
//            throw apiError.toEntity()
//        }
//    }
//
//    func getAccount(email: String) async throws -> AccountEntity {
//        let url = baseURL.appendingPathComponent("/api/accounts/\(email.lowercased())")
//        let (data, response) = try await client.get(from: url, headers: authHeaders)
//        do {
//            let dto: AccountResponse = try RemoteMapper.map(data, response, decoder: decoder)
//            return dto.toEntity()
//        } catch let apiError as ApiError {
//            throw apiError.toEntity()
//        }
//    }
//
//    func getLimits(email: String) async throws -> LimitsEntity {
//        let url = baseURL.appendingPathComponent("/api/accounts/\(email.lowercased())/limits")
//        let (data, response) = try await client.get(from: url, headers: authHeaders)
//        do {
//            let dto: LimitsResponse = try RemoteMapper.map(data, response, decoder: decoder)
//            return dto.toEntity()
//        } catch let apiError as ApiError {
//            throw apiError.toEntity()
//        }
//    }
//
//    func createWithdrawal(email: String, amountCents: Int) async throws -> TicketEntity {
//        let url = baseURL.appendingPathComponent("/api/withdrawals")
//        let requestBody = CreateWithdrawalRequest(email: email.lowercased(), amountCents: amountCents)
//        let bodyData = try encoder.encode(requestBody)
//        let (data, response) = try await client.post(to: url, data: bodyData, headers: authHeaders)
//        do {
//            let dto: TicketResponse = try RemoteMapper.map(data, response, decoder: decoder)
//            return dto.toEntity()
//        } catch let apiError as ApiError {
//            throw apiError.toEntity()
//        }
//    }
//    
//    func createValidateWithdrawal(qrPayload: String) async throws -> WithdrawalValidateEntity {
//        let url = baseURL.appendingPathComponent("/api/withdrawals/validate")
//        let requestBody = CreateWithdrawalValidateRequest(qrPayload: qrPayload, token: TokenManager.shared.token ?? "")
//        let bodyData = try encoder.encode(requestBody)
//        let (data, response) = try await client.post(to: url, data: bodyData, headers: authHeaders)
//        do {
//            let dto: CreateWithdrawalValidateResponse = try RemoteMapper.map(data, response, decoder: decoder)
//            return dto.toEntity()
//        } catch let apiError as ApiError {
//            throw apiError.toEntity()
//        }
//    }
//
//    func dispense(qrPayload: String) async throws -> DispenseEntity {
//        let url = baseURL.appendingPathComponent("/api/withdrawals/dispense")
//        let requestBody = RedeemRequest(qrPayload: qrPayload)
//        let bodyData = try encoder.encode(requestBody)
//        let (data, response) = try await client.post(to: url, data: bodyData, headers: authHeaders)
//        do {
//            let dto: DispenseResponse = try RemoteMapper.map(data, response, decoder: decoder)
//            return dto.toEntity()
//        } catch let apiError as ApiError {
//            throw apiError.toEntity()
//        }
//    }
//}
