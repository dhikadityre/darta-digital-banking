import XCTest
@testable import CoreDomain

final class DispenseUseCaseTests: XCTestCase {
    private var repositorySpy: DartaRepositorySpy!
    private var sut: DispenseUseCaseImpl!

    override func setUp() {
        super.setUp()
        repositorySpy = DartaRepositorySpy()
        sut = DispenseUseCaseImpl(repository: repositorySpy)
    }

    override func tearDown() {
        sut = nil
        repositorySpy = nil
        super.tearDown()
    }

    func test_execute_success() async throws {
        // Given
        let payload = "qr_payload_for_dispense"
        let stubbedDispense = DispenseEntity.mock(status: "SUCCESS", amountCents: 50000)
        repositorySpy.dispenseResult = .success(stubbedDispense)

        // When
        let result = try await sut.execute(qrPayload: payload)

        // Then
        XCTAssertEqual(repositorySpy.dispenseCalledCount, 1)
        XCTAssertEqual(repositorySpy.dispenseParameters, payload)
        XCTAssertEqual(result.status, "SUCCESS")
        XCTAssertEqual(result.amountCents, 50000)
    }

    func test_execute_failure() async throws {
        // Given
        let payload = "qr_payload_for_dispense"
        let expectedError = ApiErrorEntity.mock(status: 400)
        repositorySpy.dispenseResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.execute(qrPayload: payload)
            XCTFail("Expected execute to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertEqual(apiError?.status, 400)
        }

        XCTAssertEqual(repositorySpy.dispenseCalledCount, 1)
    }
}
