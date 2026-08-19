//
//  Config.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import Foundation

public enum Config {
    private enum Keys: String {
        case apiBaseUrl = "API_BASE_URL"
        case apiKey = "API_KEY"
    }

    private static let infoDictionary = Bundle.main.infoDictionary ?? [:]

    public static var apiBaseUrl: URL? {
        guard let value = stringValue(for: .apiBaseUrl) else {
            return nil
        }

        return URL(string: value)
    }

    public static var apiKey: String? {
        stringValue(for: .apiKey)
    }

    private static func stringValue(for key: Keys) -> String? {
        guard let value = infoDictionary[key.rawValue] as? String,
              !value.isEmpty else {
            return nil
        }

        return value
    }
}
