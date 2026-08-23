import XCTest
@testable import CoreDomain

final class CreateWithdrawalUseCaseTests: XCTestCase {
    private var repositorySpy: TapCashRepositorySpy!
    private var sut: CreateWithdrawalUseCaseImpl!

    override func setUp() {
        super.setUp()
        repositorySpy = TapCashRepositorySpy()
        sut = CreateWithdrawalUseCaseImpl(repository: repositorySpy)
    }

    override func tearDown() {
        sut = nil
        repositorySpy = nil
        super.tearDown()
    }

    // MARK: - Execute Tests (Create Withdrawal)

    func test_execute_success() async throws {
        // Given
        let email = "user@example.com"
        let amount = 150000
        let stubbedTicket = TicketEntity.mock(amountCents: amount)
        repositorySpy.createWithdrawalResult = .success(stubbedTicket)

        // When
        let result = try await sut.execute(email: email, amountCents: amount)

        // Then
        XCTAssertEqual(repositorySpy.createWithdrawalCalledCount, 1)
        XCTAssertEqual(repositorySpy.createWithdrawalParameters?.email, email)
        XCTAssertEqual(repositorySpy.createWithdrawalParameters?.amountCents, amount)
        XCTAssertEqual(result.amountCents, amount)
    }

    func test_execute_failure() async throws {
        // Given
        let email = "user@example.com"
        let amount = 150000
        let expectedError = ApiErrorEntity.mock(status: 400)
        repositorySpy.createWithdrawalResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.execute(email: email, amountCents: amount)
            XCTFail("Expected execute to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertEqual(apiError?.status, 400)
        }

        XCTAssertEqual(repositorySpy.createWithdrawalCalledCount, 1)
    }

    // MARK: - Validate Tests

    func test_validate_success() async throws {
        // Given
        let payload = "qr_payload_xyz"
        let stubbedValidation = WithdrawalValidateEntity.mock(qrPayload: payload)
        repositorySpy.validateWithdrawalResult = .success(stubbedValidation)

        // When
        let result = try await sut.validate(qrPayload: payload)

        // Then
        XCTAssertEqual(repositorySpy.validateWithdrawalCalledCount, 1)
        XCTAssertEqual(repositorySpy.validateWithdrawalParameters, payload)
        XCTAssertEqual(result.qrPayload, payload)
    }

    func test_validate_failure() async throws {
        // Given
        let payload = "qr_payload_xyz"
        let expectedError = ApiErrorEntity.mock(status: 400)
        repositorySpy.validateWithdrawalResult = .failure(expectedError)

        // When/Then
        do {
            _ = try await sut.validate(qrPayload: payload)
            XCTFail("Expected validate to fail, but it succeeded")
        } catch {
            let apiError = error as? ApiErrorEntity
            XCTAssertEqual(apiError?.status, 400)
        }

        XCTAssertEqual(repositorySpy.validateWithdrawalCalledCount, 1)
    }
}
