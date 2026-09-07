//
//  LoginScreenViewModel.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import Combine
import CoreDomain

@MainActor
public final class LoginScreenViewModel: ObservableObject {
    @Published var email = "alex@tapcash.demo"
    @Published var password = "cash1234"
    @Published var loading = false
    @Published var errorMessage: String?
    
    var onLoginSuccess: ((String, String, Int, LimitsEntity) -> Void)?
    
    private let loginUseCase: LoginUseCase
    
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    func login() {
        self.loading = true
        self.errorMessage = nil
        Task {
            do {
                let result = try await loginUseCase.execute(email: email, password: password)
                self.loading = false
                self.onLoginSuccess?(
                    result.account.email,
                    result.account.displayName,
                    result.account.availableBalanceCents,
                    result.limits
                )
            } catch {
                self.loading = false
                self.errorMessage = "Login failed. Check demo credentials."
            }
        }
    }
}
