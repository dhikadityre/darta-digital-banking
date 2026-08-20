//
//  HomeScreenViewModel.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import Combine

class HomeScreenViewModel: ObservableObject {
    @Published private(set) var balanceCents: Int
    @Published private(set) var displayName: String
    
    var onWithdrawSelected: (() -> Void)?
    var onScanSelected: (() -> Void)?
    
    init(displayName: String, balanceCents: Int) {
        self.displayName = displayName
        self.balanceCents = balanceCents
    }
}
