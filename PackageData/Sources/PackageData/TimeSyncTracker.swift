//
//  TimeSyncTracker.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation

public final class TimeSyncTracker: @unchecked Sendable {
    public static let shared = TimeSyncTracker()
    
    // Offset in seconds: (ServerTime - ClientLocalTime)
    private(set) public var timeOffset: TimeInterval = 0
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private init() {}
    
    // MARK: - STEP 1.1.0
    /// Sync the time using the "Date" header string from HTTP Response.
    public func syncTime(withServerDateString dateString: String) {
        guard let serverDate = formatter.date(from: dateString) else {
            // Fallback in case of slightly different format
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
            fallbackFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
            fallbackFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let serverDate = fallbackFormatter.date(from: dateString) {
                let clientDate = Date()
                self.timeOffset = serverDate.timeIntervalSince(clientDate)
            }
            return
        }
        let clientDate = Date()
        self.timeOffset = serverDate.timeIntervalSince(clientDate)
    }
    
    /// Returns the synchronized server time.
    public func serverTimeNow() -> Date {
        return Date().addingTimeInterval(timeOffset)
    }
}
