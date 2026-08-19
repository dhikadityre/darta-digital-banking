import SwiftUI

/// TapCash iOS — cardless cash withdrawal via a one-time, server-signed QR code.
/// Authentication, balances, and cash movement are SIMULATED.
@main
struct TapCashApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
