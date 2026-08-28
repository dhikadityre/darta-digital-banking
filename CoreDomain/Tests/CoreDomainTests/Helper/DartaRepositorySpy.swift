import Foundation
@testable import CoreDomain

final class DartaRepositorySpy: DartaRepository, @unchecked Sendable {
    // Stub properties
    var loginResult: Result<LoginEntity, Error>?
    var getAccountResult: Result<AccountEntity, Error>?
    var getLimitsResult: Result<LimitsEntity, Error>?
    var createWithdrawalResult: Result<TicketEntity, Error>?
    var validateWithdrawalResult: Result<WithdrawalValidateEntity, Error>?
    var dispenseResult: Result<DispenseEntity, Error>?

    // Spy tracking properties
    private(set) var loginCalledCount = 0
    private(set) var loginParameters: (email: String, password: String)?
    
    private(set) var getAccountCalledCount = 0
    private(set) var getAccountParameters: String?
    
    private(set) var getLimitsCalledCount = 0
    private(set) var getLimitsParameters: String?
    
    private(set) var createWithdrawalCalledCount = 0
    private(set) var createWithdrawalParameters: (email: String, amountCents: Int)?
    
    private(set) var validateWithdrawalCalledCount = 0
    private(set) var validateWithdrawalParameters: String?
    
    private(set) var dispenseCalledCount = 0
    private(set) var dispenseParameters: String?

    func login(email: String, password: String) async throws -> LoginEntity {
        loginCalledCount += 1
        loginParameters = (email, password)
        
        switch loginResult {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        case .none:
            fatalError("Stub loginResult not set")
        }
    }
    
    func getAccount(email: String) async throws -> AccountEntity {
        getAccountCalledCount += 1
        getAccountParameters = email
        
        switch getAccountResult {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        case .none:
            fatalError("Stub getAccountResult not set")
        }
    }
    
    func getLimits(email: String) async throws -> LimitsEntity {
        getLimitsCalledCount += 1
        getLimitsParameters = email
        
        switch getLimitsResult {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        case .none:
            fatalError("Stub getLimitsResult not set")
        }
    }
    
    func createWithdrawal(email: String, amountCents: Int) async throws -> TicketEntity {
        createWithdrawalCalledCount += 1
        createWithdrawalParameters = (email, amountCents)
        
        switch createWithdrawalResult {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        case .none:
            fatalError("Stub createWithdrawalResult not set")
        }
    }
    
    func createValidateWithdrawal(qrPayload: String) async throws -> WithdrawalValidateEntity {
        validateWithdrawalCalledCount += 1
        validateWithdrawalParameters = qrPayload
        
        switch validateWithdrawalResult {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        case .none:
            fatalError("Stub validateWithdrawalResult not set")
        }
    }
    
    func dispense(qrPayload: String) async throws -> DispenseEntity {
        dispenseCalledCount += 1
        dispenseParameters = qrPayload
        
        switch dispenseResult {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        case .none:
            fatalError("Stub dispenseResult not set")
        }
    }
}
