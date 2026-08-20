import Foundation

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

extension CreateWithdrawalValidateResponse {
    func toEntity() -> WithdrawalValidateEntity {
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
