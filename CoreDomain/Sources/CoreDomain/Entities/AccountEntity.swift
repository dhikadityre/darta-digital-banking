//
//  AccountEntity.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public struct AccountEntity {
    public let email: String
    public let displayName: String
    public let availableBalanceCents: Int
    public let currency: String
    public let simulated: Bool

    public init(email: String, displayName: String, availableBalanceCents: Int, currency: String, simulated: Bool) {
        self.email = email
        self.displayName = displayName
        self.availableBalanceCents = availableBalanceCents
        self.currency = currency
        self.simulated = simulated
    }
}
