import Foundation
@testable import CoreDomain

extension AccountEntity {
    static func mock(
        email: String = "john.doe@example.com",
        displayName: String = "John Doe",
        availableBalanceCents: Int = 5000000,
        currency: String = "IDR",
        simulated: Bool = true
    ) -> AccountEntity {
        AccountEntity(
            email: email,
            displayName: displayName,
            availableBalanceCents: availableBalanceCents,
            currency: currency,
            simulated: simulated
        )
    }
}

extension LimitsEntity {
    static func mock(
        minCents: Int = 100000,
        maxCents: Int = 2000000,
        stepCents: Int = 50000,
        dailyLimitCents: Int = 5000000,
        withdrawnTodayCents: Int = 1000000,
        remainingTodayCents: Int = 4000000,
        qrTtlSeconds: Int = 120,
        currency: String = "IDR",
        simulated: Bool = true
    ) -> LimitsEntity {
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

extension LoginEntity {
    static func mock(
        email: String = "john.doe@example.com",
        displayName: String = "John Doe",
        token: String = "mock_session_token_123"
    ) -> LoginEntity {
        LoginEntity(
            email: email,
            displayName: displayName,
            token: token
        )
    }
}

extension TicketEntity {
    static func mock(
        token: String = "mock_ticket_token_456",
        qrPayload: String = "mock_qr_payload_789",
        amountCents: Int = 200000,
        expiresAt: String = "2026-08-23T12:00:00Z",
        transactionId: String = "mock_trx_abc123",
        used: Bool = false,
        status: String = "PENDING",
        simulated: Bool = true
    ) -> TicketEntity {
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

extension WithdrawalValidateEntity {
    static func mock(
        token: String = "mock_ticket_token_456",
        qrPayload: String = "mock_qr_payload_789",
        amountCents: Int = 200000,
        expiresAt: String = "2026-08-23T12:00:00Z",
        transactionId: String = "mock_trx_abc123",
        used: Bool = false,
        status: String = "VALIDATED",
        simulated: Bool = true
    ) -> WithdrawalValidateEntity {
        WithdrawalValidateEntity(
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

extension DispenseEntity {
    static func mock(
        status: String = "SUCCESS",
        amountCents: Int = 200000,
        transactionId: String = "mock_trx_abc123",
        remainingBalanceCents: Int = 4800000,
        dispensedAt: String = "2026-08-23T06:45:00Z",
        simulated: Bool = true
    ) -> DispenseEntity {
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

extension ApiErrorEntity {
    static func mock(
        status: Int = 400,
        error: String = "BAD_REQUEST",
        message: String = "Invalid request arguments."
    ) -> ApiErrorEntity {
        ApiErrorEntity(
            status: status,
            error: error,
            message: message
        )
    }
}
