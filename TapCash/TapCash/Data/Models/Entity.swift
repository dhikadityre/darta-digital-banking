//
//  Entity.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

struct LoginEntity {
    let email: String
    let displayName: String
    let token: String
}

struct AccountEntity {
    let email: String
    let displayName: String
    let availableBalanceCents: Int
    let currency: String
    let simulated: Bool
}

struct LimitsEntity {
    let minCents: Int
    let maxCents: Int
    let stepCents: Int
    let dailyLimitCents: Int
    let withdrawnTodayCents: Int
    let remainingTodayCents: Int
    let qrTtlSeconds: Int
    let currency: String
    let simulated: Bool
}

struct TicketEntity: Identifiable {
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

struct DispenseEntity {
    let status: String
    let amountCents: Int
    let transactionId: String
    let remainingBalanceCents: Int
    let dispensedAt: String
    let simulated: Bool
}

struct ApiErrorEntity: Error {
    let status: Int
    let error: String
    let message: String
}

extension Int {
    /// Formats a cent amount as USD, e.g. 4000 -> "$40.00".
    var usd: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "en_US")
        return f.string(from: NSNumber(value: Double(self) / 100.0)) ?? "$0.00"
    }
}

