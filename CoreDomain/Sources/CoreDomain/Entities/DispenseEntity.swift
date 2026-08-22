//
//  DispenseEntity.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public struct DispenseEntity {
    public let status: String
    public let amountCents: Int
    public let transactionId: String
    public let remainingBalanceCents: Int
    public let dispensedAt: String
    public let simulated: Bool

    public init(status: String, amountCents: Int, transactionId: String, remainingBalanceCents: Int, dispensedAt: String, simulated: Bool) {
        self.status = status
        self.amountCents = amountCents
        self.transactionId = transactionId
        self.remainingBalanceCents = remainingBalanceCents
        self.dispensedAt = dispensedAt
        self.simulated = simulated
    }
}
