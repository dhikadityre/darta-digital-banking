import SwiftUI

/// Darta iOS — cardless cash withdrawal via a one-time, server-signed QR code.
/// Authentication, balances, and cash movement are SIMULATED.
@main
struct DartaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
