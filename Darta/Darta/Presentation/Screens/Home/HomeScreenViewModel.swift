//
//  HomeScreenViewModel.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import Combine
import PackageData

class HomeScreenViewModel: ObservableObject {
    @Published private(set) var balanceCents: Int
    @Published private(set) var displayName: String
    
    var onWithdrawSelected: (() -> Void)?
    var onScanSelected: (() -> Void)?
    
    private let appConfig: AppConfig
    
    var isWithdrawEnabled: Bool {
        appConfig.pocFeatureEnabled
    }
    
    init(displayName: String, balanceCents: Int, appConfig: AppConfig = DefaultAppConfig()) {
        self.displayName = displayName
        self.balanceCents = balanceCents
        self.appConfig = appConfig
    }
}
