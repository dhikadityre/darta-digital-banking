import XCTest
@testable import CoreDomain

final class GetLimitsUseCaseTests: XCTestCase {
    private var repositorySpy: DartaRepositorySpy!
    private var sut: GetLimitsUseCaseImpl!

    override func setUp() {
        super.setUp()
        repositorySpy = DartaRepositorySpy()
        sut = GetLimitsUseCaseImpl(repository: repositorySpy)
    }

    override func tearDown() {
        sut = nil
        repositorySpy = nil
        super.tearDown()
    }

    func test_execute_success() async throws {
        // Given
        let email = "user@example.com"
        let stubbedLimits = LimitsEntity.mock(maxCents: 1000000)
        repositorySpy.getLimitsResult = .success(stubbedLimits)

        // When
        let result = try await sut.execute(email: email)

        // Then
        XCTAssertEqual(repositorySpy.getLimitsCalledCount, 1)
        XCTAssertEqual(repositorySpy.getLimitsParameters, email)
        XCTAssertEqual(result.maxCents, 1000000)
    }

    func test_execute_failure() async throws {
        // Given
        let email = "user@example.com"
        let expectedError = ApiErrorEntity.mock(status: 400)
        repositorySpy.getLimitsResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.execute(email: email)
            XCTFail("Expected execute to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertEqual(apiError?.status, 400)
        }

        XCTAssertEqual(repositorySpy.getLimitsCalledCount, 1)
    }
}
