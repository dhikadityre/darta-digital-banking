//
//  WithdrawalValidateEntity.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

public struct WithdrawalValidateEntity: Identifiable {
    public let token: String
    public let qrPayload: String
    public let amountCents: Int
    public let expiresAt: String
    public let transactionId: String
    public let used: Bool
    public let status: String
    public let simulated: Bool

    public var id: String { token }

    public init(token: String, qrPayload: String, amountCents: Int, expiresAt: String, transactionId: String, used: Bool, status: String, simulated: Bool) {
        self.token = token
        self.qrPayload = qrPayload
        self.amountCents = amountCents
        self.expiresAt = expiresAt
        self.transactionId = transactionId
        self.used = used
        self.status = status
        self.simulated = simulated
    }
}
