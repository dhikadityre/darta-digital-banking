//
//  DispenseEntity.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

struct DispenseEntity {
    let status: String
    let amountCents: Int
    let transactionId: String
    let remainingBalanceCents: Int
    let dispensedAt: String
    let simulated: Bool
}
