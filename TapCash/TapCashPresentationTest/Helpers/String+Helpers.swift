//
//  String+Helpers.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 23/08/26.
//

import Foundation

func makeExpiryString(offsetBy seconds: TimeInterval) -> String {
    let date = Date().addingTimeInterval(seconds)
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: date)
}
