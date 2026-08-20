//
//  NavigationRouter.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class NavigationRouter: ObservableObject {
    enum Route: Hashable {
        case login
        case home
        case amount
        case qr
        case scan
        case result
    }
    
    @Published var path: [Route] = []
    
    var sessionEmail: String?
    var sessionDisplayName: String?
    var sessionBalanceCents: Int = 0
    var sessionLimits: LimitsEntity?
    var sessionTicket: TicketEntity?
    var sessionLastAmountCents: Int = 0
    var sessionDispenseResult: DispenseEntity?
    
    func navigateToLogin() {
        self.path = []
    }
    
    func navigateToHome(email: String, displayName: String, balanceCents: Int, limits: LimitsEntity?) {
        self.sessionEmail = email
        self.sessionDisplayName = displayName
        self.sessionBalanceCents = balanceCents
        self.sessionLimits = limits
        self.path = [.home]
    }
    
    func navigateToAmount() {
        self.path.append(.amount)
    }
    
    func navigateToQR(ticket: TicketEntity, amountCents: Int) {
        self.sessionTicket = ticket
        self.sessionLastAmountCents = amountCents
        self.path.append(.qr)
    }
    
    func navigateToScan() {
        self.path.append(.scan)
    }
    
    func navigateToResult(result: DispenseEntity) {
        self.sessionDispenseResult = result
        self.path.append(.result)
    }
}
