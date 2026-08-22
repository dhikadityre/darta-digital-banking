//
//  LimitsEntity.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public struct LimitsEntity {
    public let minCents: Int
    public let maxCents: Int
    public let stepCents: Int
    public let dailyLimitCents: Int
    public let withdrawnTodayCents: Int
    public let remainingTodayCents: Int
    public let qrTtlSeconds: Int
    public let currency: String
    public let simulated: Bool

    public init(minCents: Int, maxCents: Int, stepCents: Int, dailyLimitCents: Int, withdrawnTodayCents: Int, remainingTodayCents: Int, qrTtlSeconds: Int, currency: String, simulated: Bool) {
        self.minCents = minCents
        self.maxCents = maxCents
        self.stepCents = stepCents
        self.dailyLimitCents = dailyLimitCents
        self.withdrawnTodayCents = withdrawnTodayCents
        self.remainingTodayCents = remainingTodayCents
        self.qrTtlSeconds = qrTtlSeconds
        self.currency = currency
        self.simulated = simulated
    }
}
