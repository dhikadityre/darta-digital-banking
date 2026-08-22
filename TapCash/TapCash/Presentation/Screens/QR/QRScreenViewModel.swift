//
//  QRScreenViewModel.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import Combine
import CoreDomain
import PackageData

@MainActor
final class QRScreenViewModel: ObservableObject {
    @Published var ticket: TicketEntity?
    @Published var remainingSeconds = 0
    @Published var isRefreshing = false
    
    private var refreshed = false
    private let email: String
    private let amountCents: Int
    private let createWithdrawalUseCase: CreateWithdrawalUseCase
    private let appConfig: AppConfig
    private let now: () -> Date
    private var validationTask: Task<Void, Never>?
    private var timer: AnyCancellable?
    
    var onFinished: (() -> Void)?
    var onWithdrawalUsed: ((WithdrawalValidateEntity) -> Void)?
    
    init(
        ticket: TicketEntity?,
        email: String,
        amountCents: Int,
        createWithdrawalUseCase: CreateWithdrawalUseCase,
        appConfig: AppConfig = DefaultAppConfig(),
        now: @escaping () -> Date = { TimeSyncTracker.shared.serverTimeNow() }
    ) {
        self.ticket = ticket
        self.email = email
        self.amountCents = amountCents
        self.createWithdrawalUseCase = createWithdrawalUseCase
        self.appConfig = appConfig
        self.now = now
        syncRemaining()
        startValidationPolling()
        startTimer()
    }
    
    func syncRemaining() {
        guard let expiresAt = ticket?.expiresAt else { return }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: expiresAt) ?? ISO8601DateFormatter().date(from: expiresAt)
        if let date = date {
            // self.remainingSeconds = max(0, Int(date.timeIntervalSinceNow))
            let serverTime = self.now()
            self.remainingSeconds = max(0, Int(date.timeIntervalSince(serverTime)))
        } else {
            self.remainingSeconds = 0
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tick()
            }
    }

    func tick() {
        syncRemaining()
        if remainingSeconds <= 0 && !refreshed {
            refreshed = true
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                self.refreshTicket()
            }
        }
    }
    
    func refreshTicket() {
        guard !email.isEmpty, amountCents > 0, !isRefreshing else { return }
        isRefreshing = true
        Task {
            do {
                let fresh = try await createWithdrawalUseCase.execute(email: self.email, amountCents: self.amountCents)
                self.ticket = fresh
                self.refreshed = false
                self.syncRemaining()
                self.isRefreshing = false
                startValidationPolling()
            } catch {
                self.isRefreshing = false
                self.refreshed = false
            }
        }
    }
    
    func startValidationPolling() {
        validationTask?.cancel()
        guard let ticket = ticket else { return }
        
        let intervalSeconds = appConfig.pollingIntervalSeconds
        let nanoseconds = UInt64(max(0.1, intervalSeconds) * 1_000_000_000)
        
        validationTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: nanoseconds)
                } catch {
                    break
                }
                
                guard !Task.isCancelled else { break }
                
                guard let self = self else { break }
                
                do {
                    let validateEntity = try await self.createWithdrawalUseCase.validate(qrPayload: ticket.qrPayload)
                    if validateEntity.used {
                        self.validationTask?.cancel()
                        self.onWithdrawalUsed?(validateEntity)
                        break
                    }
                } catch {
                    // Ignore errors during polling
                }
            }
        }
    }
    
    func stopValidationPolling() {
        validationTask?.cancel()
        validationTask = nil
    }
    
    func finish() {
        stopValidationPolling()
        onFinished?()
    }
}
