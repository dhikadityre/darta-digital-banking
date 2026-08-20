//
//  Int+Extensions.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

extension Int {
    /// Formats a cent amount as USD, e.g. 4000 -> "$40.00".
    var usd: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "en_US")
        return f.string(from: NSNumber(value: Double(self) / 100.0)) ?? "$0.00"
    }
}
