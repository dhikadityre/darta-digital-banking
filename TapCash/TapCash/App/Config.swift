//
//  Config.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import Foundation

public protocol AppConfig {
    var apiBaseUrl: URL? { get }
    var pollingIntervalSeconds: Double { get }
    var pocFeatureEnabled: Bool { get }
}

public struct DefaultAppConfig: AppConfig {
    public init() {}
    public var apiBaseUrl: URL? { Config.apiBaseUrl }
    public var pollingIntervalSeconds: Double { Config.pollingIntervalSeconds }
    public var pocFeatureEnabled: Bool { Config.pocFeatureEnabled }
}

public enum Config {
    private enum Keys: String {
        case apiBaseUrl = "API_BASE_URL"
        case pollingIntervalSeconds = "POLLING_INTERVAL_SECONDS"
        case pocFeatureEnabled = "POC_FEATURE_ENABLED"
    }

    private static let infoDictionary = Bundle.main.infoDictionary ?? [:]

    public static var apiBaseUrl: URL? {
        guard let value = stringValue(for: .apiBaseUrl) else {
            return nil
        }

        return URL(string: value)
    }

    public static var pollingIntervalSeconds: Double {
        guard let value = stringValue(for: .pollingIntervalSeconds),
              let doubleValue = Double(value) else {
            return 3.0 // default fallback
        }
        return doubleValue
    }

    public static var pocFeatureEnabled: Bool {
        guard let value = stringValue(for: .pocFeatureEnabled) else {
            return false // default fallback
        }
        return value.lowercased() == "true" || value == "YES" || value == "1"
    }

    private static func stringValue(for key: Keys) -> String? {
        guard let value = infoDictionary[key.rawValue] as? String,
              !value.isEmpty else {
            return nil
        }

        return value
    }
}
