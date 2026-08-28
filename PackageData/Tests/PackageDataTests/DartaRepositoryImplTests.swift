import XCTest
import CoreDomain
@testable import PackageData

final class DartaRepositoryImplTests: XCTestCase {
    private var clientStub: HTTPClientStub!
    private var fakeStorage: FakeTokenStorage!
    private var sut: DartaRepositoryImpl!
    private let baseURL = URL(string: "https://api.example.com")!
    
    override func setUp() {
        super.setUp()
        clientStub = HTTPClientStub()
        fakeStorage = FakeTokenStorage()
        TokenManager.shared.storage = fakeStorage
        sut = DartaRepositoryImpl(client: clientStub, baseURL: baseURL)
    }
    
    override func tearDown() {
        sut = nil
        clientStub = nil
        fakeStorage = nil
        TokenManager.shared.clear()
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func makeHTTPURLResponse(statusCode: Int, dateHeader: String? = nil) -> HTTPURLResponse {
        var headers = ["Content-Type": "application/json"]
        if let dateHeader = dateHeader {
            headers["Date"] = dateHeader
        }
        return HTTPURLResponse(url: baseURL, statusCode: statusCode, httpVersion: nil, headerFields: headers)!
    }
    
    private func makeJSONData(_ dictionary: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: dictionary)
    }
    
    // MARK: - Login Tests
    
    func test_login_success() async throws {
        let expectedEmail = "test@example.com"
        let expectedToken = "mock-token-123"
        let expectedRefreshToken = "mock-refresh-456"
        let loginResponseData = makeJSONData([
            "email": expectedEmail,
            "displayName": "Test User",
            "token": expectedToken,
            "refreshToken": expectedRefreshToken
        ])
        
        clientStub.stub(.success((loginResponseData, makeHTTPURLResponse(statusCode: 200))))
        
        let entity = try await sut.login(email: expectedEmail, password: "password123")
        
        XCTAssertEqual(entity.email, expectedEmail)
        XCTAssertEqual(entity.displayName, "Test User")
        XCTAssertEqual(entity.token, expectedToken)
        
        XCTAssertEqual(TokenManager.shared.token, expectedToken)
        XCTAssertEqual(TokenManager.shared.refreshToken, expectedRefreshToken)
        
        let calls = clientStub.requestCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].url, baseURL.appendingPathComponent("/api/auth/login"))
        XCTAssertEqual(calls[0].method, "POST")
        
        let decodedBody = try! JSONDecoder().decode([String: String].self, from: calls[0].data!)
        XCTAssertEqual(decodedBody["email"], expectedEmail)
        XCTAssertEqual(decodedBody["password"], "password123")
    }
    
    func test_login_failure() async throws {
        let errorData = makeJSONData([
            "status": 401,
            "error": "Unauthorized",
            "message": "Invalid password"
        ])
        
        clientStub.stub(.success((errorData, makeHTTPURLResponse(statusCode: 401))))
        
        do {
            _ = try await sut.login(email: "test@example.com", password: "wrong-password")
            XCTFail("Expected login to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertNotNil(apiError)
            XCTAssertEqual(apiError?.status, 401)
            XCTAssertEqual(apiError?.error, "Unauthorized")
            XCTAssertEqual(apiError?.message, "Invalid password")
        }
    }
    
    // MARK: - Get Account Tests
    
    func test_getAccount_success() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let accountResponseData = makeJSONData([
            "email": "user@example.com",
            "displayName": "User Display Name",
            "availableBalanceCents": 5000,
            "currency": "IDR",
            "simulated": false
        ])
        
        clientStub.stub(.success((accountResponseData, makeHTTPURLResponse(statusCode: 200))))
        
        let entity = try await sut.getAccount(email: "user@example.com")
        
        XCTAssertEqual(entity.email, "user@example.com")
        XCTAssertEqual(entity.displayName, "User Display Name")
        XCTAssertEqual(entity.availableBalanceCents, 5000)
        XCTAssertEqual(entity.currency, "IDR")
        XCTAssertFalse(entity.simulated)
        
        let calls = clientStub.requestCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].url, baseURL.appendingPathComponent("/api/accounts/user@example.com"))
        XCTAssertEqual(calls[0].method, "GET")
        XCTAssertEqual(calls[0].headers?["Authorization"], "Bearer auth-token-xyz")
    }
    
    func test_getAccount_failure() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let errorData = makeJSONData([
            "status": 404,
            "error": "Not Found",
            "message": "Account not found"
        ])
        
        clientStub.stub(.success((errorData, makeHTTPURLResponse(statusCode: 404))))
        
        do {
            _ = try await sut.getAccount(email: "nonexistent@example.com")
            XCTFail("Expected getAccount to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertNotNil(apiError)
            XCTAssertEqual(apiError?.status, 404)
        }
    }
    
    // MARK: - Get Limits Tests
    
    func test_getLimits_success() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let limitsResponseData = makeJSONData([
            "minCents": 100,
            "maxCents": 100000,
            "stepCents": 10,
            "dailyLimitCents": 500000,
            "withdrawnTodayCents": 2000,
            "remainingTodayCents": 498000,
            "qrTtlSeconds": 60,
            "currency": "IDR",
            "simulated": true
        ])
        
        clientStub.stub(.success((limitsResponseData, makeHTTPURLResponse(statusCode: 200))))
        
        let entity = try await sut.getLimits(email: "user@example.com")
        
        XCTAssertEqual(entity.minCents, 100)
        XCTAssertEqual(entity.maxCents, 100000)
        XCTAssertEqual(entity.stepCents, 10)
        XCTAssertEqual(entity.dailyLimitCents, 500000)
        XCTAssertEqual(entity.withdrawnTodayCents, 2000)
        XCTAssertEqual(entity.remainingTodayCents, 498000)
        XCTAssertEqual(entity.qrTtlSeconds, 60)
        XCTAssertEqual(entity.currency, "IDR")
        XCTAssertTrue(entity.simulated)
        
        let calls = clientStub.requestCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].url, baseURL.appendingPathComponent("/api/accounts/user@example.com/limits"))
        XCTAssertEqual(calls[0].method, "GET")
        XCTAssertEqual(calls[0].headers?["Authorization"], "Bearer auth-token-xyz")
    }
    
    func test_getLimits_failure() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let errorData = makeJSONData([
            "status": 500,
            "error": "Internal Error",
            "message": "Database disconnected"
        ])
        
        clientStub.stub(.success((errorData, makeHTTPURLResponse(statusCode: 500))))
        
        do {
            _ = try await sut.getLimits(email: "user@example.com")
            XCTFail("Expected getLimits to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertNotNil(apiError)
            XCTAssertEqual(apiError?.status, 500)
        }
    }
    
    // MARK: - Create Withdrawal Tests
    
    func test_createWithdrawal_success() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let ticketResponseData = makeJSONData([
            "token": "ticket-token",
            "qrPayload": "qr-payload-str",
            "amountCents": 15000,
            "expiresAt": "2026-08-23T12:00:00Z",
            "transactionId": "txn-999",
            "used": false,
            "status": "pending",
            "simulated": false
        ])
        
        clientStub.stub(.success((ticketResponseData, makeHTTPURLResponse(statusCode: 200))))
        
        let entity = try await sut.createWithdrawal(email: "user@example.com", amountCents: 15000)
        
        XCTAssertEqual(entity.token, "ticket-token")
        XCTAssertEqual(entity.qrPayload, "qr-payload-str")
        XCTAssertEqual(entity.amountCents, 15000)
        XCTAssertEqual(entity.expiresAt, "2026-08-23T12:00:00Z")
        XCTAssertEqual(entity.transactionId, "txn-999")
        XCTAssertFalse(entity.used)
        XCTAssertEqual(entity.status, "pending")
        XCTAssertFalse(entity.simulated)
        
        let calls = clientStub.requestCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].url, baseURL.appendingPathComponent("/api/withdrawals"))
        XCTAssertEqual(calls[0].method, "POST")
        XCTAssertEqual(calls[0].headers?["Authorization"], "Bearer auth-token-xyz")
        
        struct ExpectedBody: Decodable {
            let email: String
            let amountCents: Int
        }
        let decodedBody = try! JSONDecoder().decode(ExpectedBody.self, from: calls[0].data!)
        XCTAssertEqual(decodedBody.email, "user@example.com")
        XCTAssertEqual(decodedBody.amountCents, 15000)
    }
    
    func test_createWithdrawal_failure() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let errorData = makeJSONData([
            "status": 400,
            "error": "Bad Request",
            "message": "Insufficient funds"
        ])
        
        clientStub.stub(.success((errorData, makeHTTPURLResponse(statusCode: 400))))
        
        do {
            _ = try await sut.createWithdrawal(email: "user@example.com", amountCents: 5000000)
            XCTFail("Expected createWithdrawal to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertNotNil(apiError)
            XCTAssertEqual(apiError?.status, 400)
        }
    }
    
    // MARK: - Create Validate Withdrawal Tests
    
    func test_createValidateWithdrawal_success() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let validateResponseData = makeJSONData([
            "token": "ticket-token",
            "qrPayload": "qr-payload-str",
            "amountCents": 20000,
            "expiresAt": "2026-08-23T12:30:00Z",
            "transactionId": "txn-888",
            "used": true,
            "status": "validated",
            "simulated": true
        ])
        
        clientStub.stub(.success((validateResponseData, makeHTTPURLResponse(statusCode: 200))))
        
        let entity = try await sut.createValidateWithdrawal(qrPayload: "qr-payload-str")
        
        XCTAssertEqual(entity.token, "ticket-token")
        XCTAssertEqual(entity.qrPayload, "qr-payload-str")
        XCTAssertEqual(entity.amountCents, 20000)
        XCTAssertEqual(entity.expiresAt, "2026-08-23T12:30:00Z")
        XCTAssertEqual(entity.transactionId, "txn-888")
        XCTAssertTrue(entity.used)
        XCTAssertEqual(entity.status, "validated")
        XCTAssertTrue(entity.simulated)
        
        let calls = clientStub.requestCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].url, baseURL.appendingPathComponent("/api/withdrawals/validate"))
        XCTAssertEqual(calls[0].method, "POST")
        XCTAssertEqual(calls[0].headers?["Authorization"], "Bearer auth-token-xyz")
        
        struct ExpectedBody: Decodable {
            let qrPayload: String
            let token: String
        }
        let decodedBody = try! JSONDecoder().decode(ExpectedBody.self, from: calls[0].data!)
        XCTAssertEqual(decodedBody.qrPayload, "qr-payload-str")
        XCTAssertEqual(decodedBody.token, "auth-token-xyz")
    }
    
    func test_createValidateWithdrawal_failure() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let errorData = makeJSONData([
            "status": 404,
            "error": "Not Found",
            "message": "Ticket expired or not found"
        ])
        
        clientStub.stub(.success((errorData, makeHTTPURLResponse(statusCode: 404))))
        
        do {
            _ = try await sut.createValidateWithdrawal(qrPayload: "expired-qr")
            XCTFail("Expected createValidateWithdrawal to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertNotNil(apiError)
            XCTAssertEqual(apiError?.status, 404)
        }
    }
    
    // MARK: - Dispense Tests
    
    func test_dispense_success() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let dispenseResponseData = makeJSONData([
            "status": "success",
            "amountCents": 10000,
            "transactionId": "txn-555",
            "remainingBalanceCents": 15000,
            "dispensedAt": "2026-08-23T12:05:00Z",
            "simulated": false
        ])
        
        clientStub.stub(.success((dispenseResponseData, makeHTTPURLResponse(statusCode: 200))))
        
        let entity = try await sut.dispense(qrPayload: "qr-payload-str")
        
        XCTAssertEqual(entity.status, "success")
        XCTAssertEqual(entity.amountCents, 10000)
        XCTAssertEqual(entity.transactionId, "txn-555")
        XCTAssertEqual(entity.remainingBalanceCents, 15000)
        XCTAssertEqual(entity.dispensedAt, "2026-08-23T12:05:00Z")
        XCTAssertFalse(entity.simulated)
        
        let calls = clientStub.requestCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].url, baseURL.appendingPathComponent("/api/withdrawals/dispense"))
        XCTAssertEqual(calls[0].method, "POST")
        XCTAssertEqual(calls[0].headers?["Authorization"], "Bearer auth-token-xyz")
        
        struct ExpectedBody: Decodable {
            let qrPayload: String
        }
        let decodedBody = try! JSONDecoder().decode(ExpectedBody.self, from: calls[0].data!)
        XCTAssertEqual(decodedBody.qrPayload, "qr-payload-str")
    }
    
    func test_dispense_failure() async throws {
        fakeStorage.accessToken = "auth-token-xyz"
        let errorData = makeJSONData([
            "status": 500,
            "error": "Dispense Error",
            "message": "Hardware failure"
        ])
        
        clientStub.stub(.success((errorData, makeHTTPURLResponse(statusCode: 500))))
        
        do {
            _ = try await sut.dispense(qrPayload: "qr-payload-str")
            XCTFail("Expected dispense to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertNotNil(apiError)
            XCTAssertEqual(apiError?.status, 500)
        }
    }
}
