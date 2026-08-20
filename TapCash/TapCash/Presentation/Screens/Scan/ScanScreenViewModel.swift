//
//  ScanScreenViewModel.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import Combine

@MainActor
final class ScanScreenViewModel: ObservableObject {
    @Published var loading = false
    @Published var scanError: String?
    
    private let dispenseUseCase: DispenseUseCase
    
    var onDispenseCompleted: ((DispenseEntity) -> Void)?
    var onCancelled: (() -> Void)?
    
    init(dispenseUseCase: DispenseUseCase) {
        self.dispenseUseCase = dispenseUseCase
    }
    
    func dispenseScanned(qrPayload: String) {
        guard !loading else { return }
        self.loading = true
        self.scanError = nil
        Task {
            do {
                let result = try await dispenseUseCase.execute(qrPayload: qrPayload)
                self.loading = false
                self.onDispenseCompleted?(result)
            } catch let apiError as ApiErrorEntity {
                self.loading = false
                self.scanError = apiError.message
            } catch {
                self.loading = false
                self.scanError = "Code rejected. It may be used, expired, or invalid."
            }
        }
    }
    
    func cancel() {
        self.onCancelled?()
    }
}
