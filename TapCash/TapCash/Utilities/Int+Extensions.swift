//
//  Int+Extensions.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

extension Int {
    /// Formats an amount as Rupiah, e.g. 4000 -> "Rp 4.000".
    var rupiah: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "id_ID")
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: self)) ?? "Rp0"
    }
}
