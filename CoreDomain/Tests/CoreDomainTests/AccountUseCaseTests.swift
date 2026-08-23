import XCTest
@testable import CoreDomain

final class AccountUseCaseTests: XCTestCase {
    private var repositorySpy: TapCashRepositorySpy!
    private var sut: AccountUseCaseImpl!

    override func setUp() {
        super.setUp()
        repositorySpy = TapCashRepositorySpy()
        sut = AccountUseCaseImpl(repository: repositorySpy)
    }

    override func tearDown() {
        sut = nil
        repositorySpy = nil
        super.tearDown()
    }

    func test_execute_success() async throws {
        // Given
        let email = "user@example.com"
        let stubbedAccount = AccountEntity.mock(email: email, displayName: "Test User")
        repositorySpy.getAccountResult = .success(stubbedAccount)

        // When
        let result = try await sut.execute(email: email)

        // Then
        XCTAssertEqual(repositorySpy.getAccountCalledCount, 1)
        XCTAssertEqual(repositorySpy.getAccountParameters, email)
        XCTAssertEqual(result.email, email)
        XCTAssertEqual(result.displayName, "Test User")
    }

    func test_execute_failure() async throws {
        // Given
        let email = "user@example.com"
        let expectedError = ApiErrorEntity.mock(status: 400)
        repositorySpy.getAccountResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.execute(email: email)
            XCTFail("Expected execute to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertEqual(apiError?.status, 400)
        }

        XCTAssertEqual(repositorySpy.getAccountCalledCount, 1)
        XCTAssertEqual(repositorySpy.getAccountParameters, email)
    }
}
