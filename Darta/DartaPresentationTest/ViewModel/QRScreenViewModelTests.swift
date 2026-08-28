//
//  QRScreenViewModelTests.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 23/08/26.
//

import Foundation
import Testing
import CoreDomain
@testable import Darta

@Suite @MainActor
struct QRScreenViewModelTests {
    
    @Test func testInitializationAndPollingStarted() async throws {
        let spy = CreateWithdrawalUseCaseSpy()
        let config = AppConfigStub()
        
        let futureDateString = makeExpiryString(offsetBy: 120)
        let ticket = TicketEntity(
            token: "tok_111",
            qrPayload: "TC1.somepayload",
            amountCents: 2000,
            expiresAt: futureDateString,
            transactionId: "tx_111",
            used: false,
            status: "pending",
            simulated: true
        )
        
        spy.validateResult = WithdrawalValidateEntity(
            token: "tok_111",
            qrPayload: "TC1.somepayload",
            amountCents: 2000,
            expiresAt: futureDateString,
            transactionId: "tx_111",
            used: false,
            status: "pending",
            simulated: true
        )
        
        let viewModel = QRScreenViewModel(
            ticket: ticket,
            email: "alex@darta.demo",
            amountCents: 2000,
            createWithdrawalUseCase: spy,
            appConfig: config
        )
        
        #expect(viewModel.ticket?.token == "tok_111")
        #expect(viewModel.remainingSeconds > 0)
        #expect(viewModel.remainingSeconds <= 120)
        #expect(viewModel.isRefreshing == false)
        
        viewModel.stopValidationPolling()
    }
    
    @Test func testExpiryLogic_RemainingSecondsCalculation() async throws {
        let spy = CreateWithdrawalUseCaseSpy()
        let config = AppConfigStub()
        
        let pastDateString = makeExpiryString(offsetBy: -30)
        let ticket = TicketEntity(
            token: "tok_expired",
            qrPayload: "TC1.expired_payload",
            amountCents: 1000,
            expiresAt: pastDateString,
            transactionId: "tx_expired",
            used: false,
            status: "expired",
            simulated: true
        )
        
        spy.validateResult = WithdrawalValidateEntity(
            token: "tok_expired",
            qrPayload: "TC1.expired_payload",
            amountCents: 1000,
            expiresAt: pastDateString,
            transactionId: "tx_expired",
            used: false,
            status: "expired",
            simulated: true
        )
        
        let viewModel = QRScreenViewModel(
            ticket: ticket,
            email: "alex@darta.demo",
            amountCents: 1000,
            createWithdrawalUseCase: spy,
            appConfig: config
        )
        
        #expect(viewModel.remainingSeconds == 0)
        
        viewModel.stopValidationPolling()
    }
    
    @Test func testExpiryLogic_SilentRefresh() async throws {
        let spy = CreateWithdrawalUseCaseSpy()
        let config = AppConfigStub()
        
        let pastDateString = makeExpiryString(offsetBy: -10)
        let ticket = TicketEntity(
            token: "tok_old",
            qrPayload: "TC1.payload_old",
            amountCents: 5000,
            expiresAt: pastDateString,
            transactionId: "tx_old",
            used: false,
            status: "expired",
            simulated: true
        )
        
        let freshTicket = TicketEntity(
            token: "tok_new",
            qrPayload: "TC1.payload_new",
            amountCents: 5000,
            expiresAt: makeExpiryString(offsetBy: 60),
            transactionId: "tx_new",
            used: false,
            status: "pending",
            simulated: true
        )
        spy.executeResult = freshTicket
        spy.validateResult = WithdrawalValidateEntity(
            token: "tok_old",
            qrPayload: "TC1.payload_old",
            amountCents: 5000,
            expiresAt: pastDateString,
            transactionId: "tx_old",
            used: false,
            status: "expired",
            simulated: true
        )
        
        let viewModel = QRScreenViewModel(
            ticket: ticket,
            email: "alex@darta.demo",
            amountCents: 5000,
            createWithdrawalUseCase: spy,
            appConfig: config
        )
        
        // Direct call to refreshTicket() triggers execution
        viewModel.refreshTicket()
        
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms
        
        #expect(spy.executeCalled == true)
        #expect(spy.executeCalledEmail == "alex@darta.demo")
        #expect(spy.executeCalledAmountCents == 5000)
        #expect(viewModel.ticket?.token == "tok_new")
        #expect(viewModel.remainingSeconds > 0)
        
        viewModel.stopValidationPolling()
    }
    
    @Test func testDuplicateRedeem_PollingStopsWhenRedeemed() async throws {
        let spy = CreateWithdrawalUseCaseSpy()
        let config = AppConfigStub(pollingIntervalSeconds: 0.01)
        
        let ticket = TicketEntity(
            token: "tok_polling",
            qrPayload: "TC1.payload_polling",
            amountCents: 3000,
            expiresAt: makeExpiryString(offsetBy: 120),
            transactionId: "tx_polling",
            used: false,
            status: "pending",
            simulated: true
        )
        
        // Return used = true during validation
        let validateResult = WithdrawalValidateEntity(
            token: "tok_polling",
            qrPayload: "TC1.payload_polling",
            amountCents: 3000,
            expiresAt: makeExpiryString(offsetBy: 120),
            transactionId: "tx_polling",
            used: true, // Marked as used!
            status: "success",
            simulated: true
        )
        spy.validateResult = validateResult
        
        let viewModel = QRScreenViewModel(
            ticket: ticket,
            email: "alex@darta.demo",
            amountCents: 3000,
            createWithdrawalUseCase: spy,
            appConfig: config
        )
        
        var withdrawalUsedCalled = false
        var receivedValidateEntity: WithdrawalValidateEntity?
        
        viewModel.onWithdrawalUsed = { entity in
            withdrawalUsedCalled = true
            receivedValidateEntity = entity
        }
        
        // Let the polling task run one iteration
        try await Task.sleep(nanoseconds: 150_000_000) // 150ms
        
        #expect(spy.validateCalled == true)
        #expect(spy.validateCalledPayload == "TC1.payload_polling")
        #expect(withdrawalUsedCalled == true)
        #expect(receivedValidateEntity?.used == true)
        
        viewModel.stopValidationPolling()
    }
    
    @Test func testCancelFlow() async throws {
        let spy = CreateWithdrawalUseCaseSpy()
        let config = AppConfigStub()
        
        let ticket = TicketEntity(
            token: "tok_cancel",
            qrPayload: "TC1.payload_cancel",
            amountCents: 1000,
            expiresAt: makeExpiryString(offsetBy: 60),
            transactionId: "tx_cancel",
            used: false,
            status: "pending",
            simulated: true
        )
        
        spy.validateResult = WithdrawalValidateEntity(
            token: "tok_cancel",
            qrPayload: "TC1.payload_cancel",
            amountCents: 1000,
            expiresAt: makeExpiryString(offsetBy: 60),
            transactionId: "tx_cancel",
            used: false,
            status: "pending",
            simulated: true
        )
        
        let viewModel = QRScreenViewModel(
            ticket: ticket,
            email: "alex@darta.demo",
            amountCents: 1000,
            createWithdrawalUseCase: spy,
            appConfig: config
        )
        
        var finishedCalled = false
        viewModel.onFinished = {
            finishedCalled = true
        }
        
        viewModel.finish()
        
        #expect(finishedCalled == true)
        
        viewModel.stopValidationPolling()
    }
}
