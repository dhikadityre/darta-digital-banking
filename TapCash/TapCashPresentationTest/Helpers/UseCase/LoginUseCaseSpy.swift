//
//  LoginUseCaseSpy.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 23/08/26.
//

import Foundation
import CoreDomain
@testable import TapCash

final class LoginUseCaseSpy: LoginUseCase {
    var executeCalled = false
    var calledEmail: String?
    var calledPassword: String?
    
    var resultToReturn: (account: AccountEntity, limits: LimitsEntity)?
    var errorToThrow: Error?
    
    func execute(email: String, password: String) async throws -> (account: AccountEntity, limits: LimitsEntity) {
        executeCalled = true
        calledEmail = email
        calledPassword = password
        
        if let error = errorToThrow {
            throw error
        }
        
        if let result = resultToReturn {
            return result
        }
        
        throw NSError(domain: "LoginUseCaseSpy", code: 401, userInfo: [NSLocalizedDescriptionKey: "No stubbed result or error"])
    }
}
