//
//  ResultScreenViewModel.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import Combine
import CoreDomain

class ResultScreenViewModel: ObservableObject {
    @Published private(set) var dispenseResult: DispenseEntity?
    
    var onDone: (() -> Void)?
    
    init(dispenseResult: DispenseEntity?) {
        self.dispenseResult = dispenseResult
    }
    
    func done() {
        self.onDone?()
    }
}
