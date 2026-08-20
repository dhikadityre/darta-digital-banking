//
//  WithdrawalValidateEntity.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

struct WithdrawalValidateEntity: Identifiable {
    let token: String
    let qrPayload: String
    let amountCents: Int
    let expiresAt: String
    let transactionId: String
    let used: Bool
    let status: String
    let simulated: Bool

    var id: String { token }
}
