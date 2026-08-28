//
//  CreateWithdrawalUseCaseSpy.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 23/08/26.
//

import Foundation
import CoreDomain
@testable import Darta

final class CreateWithdrawalUseCaseSpy: CreateWithdrawalUseCase, @unchecked Sendable {
    var executeCalled = false
    var executeCalledEmail: String?
    var executeCalledAmountCents: Int?
    var executeResult: TicketEntity?
    var executeError: Error?
    
    var validateCalled = false
    var validateCalledPayload: String?
    var validateResult: WithdrawalValidateEntity?
    var validateError: Error?
    
    func execute(email: String, amountCents: Int) async throws -> TicketEntity {
        executeCalled = true
        executeCalledEmail = email
        executeCalledAmountCents = amountCents
        
        if let error = executeError {
            throw error
        }
        if let result = executeResult {
            return result
        }
        throw NSError(domain: "CreateWithdrawalUseCaseSpy", code: 400, userInfo: [NSLocalizedDescriptionKey: "No stubbed result"])
    }
    
    func validate(qrPayload: String) async throws -> WithdrawalValidateEntity {
        validateCalled = true
        validateCalledPayload = qrPayload
        
        if let error = validateError {
            throw error
        }
        if let result = validateResult {
            return result
        }
        throw NSError(domain: "CreateWithdrawalUseCaseSpy", code: 400, userInfo: [NSLocalizedDescriptionKey: "No stubbed result"])
    }
}
