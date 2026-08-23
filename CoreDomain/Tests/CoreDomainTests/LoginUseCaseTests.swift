import XCTest
@testable import CoreDomain

final class LoginUseCaseTests: XCTestCase {
    private var repositorySpy: TapCashRepositorySpy!
    private var sut: LoginUseCaseImpl!

    override func setUp() {
        super.setUp()
        repositorySpy = TapCashRepositorySpy()
        sut = LoginUseCaseImpl(repository: repositorySpy)
    }

    override func tearDown() {
        sut = nil
        repositorySpy = nil
        super.tearDown()
    }

    func test_execute_success() async throws {
        // Given
        let expectedEmail = "user@example.com"
        let expectedPassword = "password123"
        let stubbedLogin = LoginEntity.mock(email: expectedEmail)
        let stubbedAccount = AccountEntity.mock(email: expectedEmail)
        let stubbedLimits = LimitsEntity.mock()

        repositorySpy.loginResult = .success(stubbedLogin)
        repositorySpy.getAccountResult = .success(stubbedAccount)
        repositorySpy.getLimitsResult = .success(stubbedLimits)

        // When
        let (account, limits) = try await sut.execute(email: expectedEmail, password: expectedPassword)

        // Then
        XCTAssertEqual(repositorySpy.loginCalledCount, 1)
        XCTAssertEqual(repositorySpy.loginParameters?.email, expectedEmail)
        XCTAssertEqual(repositorySpy.loginParameters?.password, expectedPassword)

        XCTAssertEqual(repositorySpy.getAccountCalledCount, 1)
        XCTAssertEqual(repositorySpy.getAccountParameters, expectedEmail)

        XCTAssertEqual(repositorySpy.getLimitsCalledCount, 1)
        XCTAssertEqual(repositorySpy.getLimitsParameters, expectedEmail)

        XCTAssertEqual(account.email, expectedEmail)
        XCTAssertEqual(limits.currency, stubbedLimits.currency)
    }

    func test_execute_loginFailure() async throws {
        // Given
        let expectedError = ApiErrorEntity.mock(status: 401, error: "UNAUTHORIZED", message: "Invalid credentials")
        repositorySpy.loginResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.execute(email: "any@example.com", password: "wrong")
            XCTFail("Expected execute to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertEqual(apiError?.status, 401)
            XCTAssertEqual(apiError?.error, "UNAUTHORIZED")
        }

        XCTAssertEqual(repositorySpy.loginCalledCount, 1)
        XCTAssertEqual(repositorySpy.getAccountCalledCount, 0)
        XCTAssertEqual(repositorySpy.getLimitsCalledCount, 0)
    }

    func test_execute_getAccountFailure() async throws {
        // Given
        let expectedEmail = "user@example.com"
        let stubbedLogin = LoginEntity.mock(email: expectedEmail)
        let expectedError = ApiErrorEntity.mock(status: 404, error: "NOT_FOUND", message: "Account not found")

        repositorySpy.loginResult = .success(stubbedLogin)
        repositorySpy.getAccountResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.execute(email: expectedEmail, password: "password123")
            XCTFail("Expected execute to fail on getAccount, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertEqual(apiError?.status, 404)
        }

        XCTAssertEqual(repositorySpy.loginCalledCount, 1)
        XCTAssertEqual(repositorySpy.getAccountCalledCount, 1)
        XCTAssertEqual(repositorySpy.getLimitsCalledCount, 0)
    }

    func test_execute_getLimitsFailure() async throws {
        // Given
        let expectedEmail = "user@example.com"
        let stubbedLogin = LoginEntity.mock(email: expectedEmail)
        let stubbedAccount = AccountEntity.mock(email: expectedEmail)
        let expectedError = ApiErrorEntity.mock(status: 500, error: "INTERNAL_ERROR", message: "Database down")

        repositorySpy.loginResult = .success(stubbedLogin)
        repositorySpy.getAccountResult = .success(stubbedAccount)
        repositorySpy.getLimitsResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.execute(email: expectedEmail, password: "password123")
            XCTFail("Expected execute to fail on getLimits, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertEqual(apiError?.status, 500)
        }

        XCTAssertEqual(repositorySpy.loginCalledCount, 1)
        XCTAssertEqual(repositorySpy.getAccountCalledCount, 1)
        XCTAssertEqual(repositorySpy.getLimitsCalledCount, 1)
    }
}
