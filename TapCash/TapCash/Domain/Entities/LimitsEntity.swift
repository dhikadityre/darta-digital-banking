//
//  LimitsEntity.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

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
