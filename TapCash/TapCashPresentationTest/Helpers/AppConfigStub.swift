//
//  AppConfigStub.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 23/08/26.
//

import Foundation
import PackageData
import TapCash

struct AppConfigStub: AppConfig {
    var apiBaseUrl: URL? = URL(string: "https://mock.tapcash.demo")
    var pollingIntervalSeconds: Double = 0.01 // Run fast in tests
    var pocFeatureEnabled: Bool = true
}
