//
//  LoginScreenViewModelTests.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 23/08/26.
//

import Foundation
import Testing
import CoreDomain
@testable import Darta

@Suite @MainActor
struct LoginScreenViewModelTests {
    
    @Test func testInitialization() {
        let spy = LoginUseCaseSpy()
        let viewModel = LoginScreenViewModel(loginUseCase: spy)
        
        #expect(viewModel.email == "alex@darta.demo")
        #expect(viewModel.password == "cash1234")
        #expect(viewModel.loading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func testLoginSuccess() async throws {
        let spy = LoginUseCaseSpy()
        let account = AccountEntity(
            email: "alex@darta.demo",
            displayName: "Alex Demo",
            availableBalanceCents: 15000,
            currency: "IDR",
            simulated: true
        )
        let limits = LimitsEntity(
            minCents: 1000,
            maxCents: 50000,
            stepCents: 1000,
            dailyLimitCents: 100000,
            withdrawnTodayCents: 0,
            remainingTodayCents: 100000,
            qrTtlSeconds: 60,
            currency: "IDR",
            simulated: true
        )
        spy.resultToReturn = (account, limits)
        
        let viewModel = LoginScreenViewModel(loginUseCase: spy)
        
        var loginSuccessCalled = false
        var successEmail: String?
        var successName: String?
        var successBalance = 0
        
        viewModel.onLoginSuccess = { email, name, balance, _ in
            loginSuccessCalled = true
            successEmail = email
            successName = name
            successBalance = balance
        }
        
        viewModel.login()
        
        // Wait for the async task to execute
        try await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(spy.executeCalled == true)
        #expect(spy.calledEmail == "alex@darta.demo")
        #expect(spy.calledPassword == "cash1234")
        #expect(viewModel.loading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(loginSuccessCalled == true)
        #expect(successEmail == "alex@darta.demo")
        #expect(successName == "Alex Demo")
        #expect(successBalance == 15000)
    }
    
    @Test func testLoginFailure() async throws {
        let spy = LoginUseCaseSpy()
        spy.errorToThrow = NSError(domain: "AuthError", code: 401, userInfo: nil)
        
        let viewModel = LoginScreenViewModel(loginUseCase: spy)
        
        var loginSuccessCalled = false
        viewModel.onLoginSuccess = { _, _, _, _ in
            loginSuccessCalled = true
        }
        
        viewModel.login()
        
        try await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(spy.executeCalled == true)
        #expect(viewModel.loading == false)
        #expect(viewModel.errorMessage == "Login failed. Check demo credentials.")
        #expect(loginSuccessCalled == false)
    }
}
