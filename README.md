# TapCash iOS (SwiftUI)

Native iOS client. It logs in, shows the SIMULATED balance and **withdrawal limits**, lets the
customer choose an amount, asks the Spring Boot backend to mint a one-time QR ticket, and renders
that server-signed payload as a QR code (CoreImage). It also has an **ATM mode** that scans a code
live with the camera and redeems it.

## Features

- **Withdrawal limits**: `/api/accounts/{email}/limits` drives a card on the amount screen
  (per-transaction range, daily limit, used today, remaining) and disables over-limit amounts.
- **Live countdown + auto-refresh**: the QR screen counts down from the ticket's absolute expiry
  and silently mints a fresh code when it expires, so an expired code never confuses the customer.
- **Camera scanning (ATM mode)**: `AVCaptureMetadataOutput` decodes a `TC1.…` QR and calls
  `/api/withdrawals/dispense`. Permission is requested contextually with a graceful
  denied → "Open Settings" fallback.

## Architecture

```
TapCashApp ──> RootView ──> Login / Home / Amount / QR / Scan / Result
    views  ──> WithdrawalViewModel (@MainActor, ObservableObject)
    net    ──> APIClient (async/await URLSession) ──> Spring Boot API
    render ──> QRCode (CIFilter) draws the payload; QRScannerView (AVFoundation) reads it
```

## Create the Xcode project

These are plain Swift sources. To build:

1. Xcode → New → App (SwiftUI, Swift). Product name **TapCash**, bundle id `com.tapcash.atm`.
2. Delete the generated `TapCashApp.swift` / `ContentView.swift` and drag every file from
   `native/ios/TapCash/` into the target.
3. Set the API host in `APIClient.swift` (`baseURL`). Simulator → `http://localhost:8080`;
   a physical device needs your Mac's LAN IP.
4. Add these Info.plist keys:
   - `NSCameraUsageDescription` → "Scan a TapCash code to withdraw cash"
   - For cleartext HTTP in dev: `NSAppTransportSecurity` → `NSAllowsLocalNetworking = YES`

Requires iOS 16+. Camera scanning needs a real device (the Simulator has no camera).

## Demo credentials

`alex@tapcash.demo` / `cash1234`

All balances and cash movement are SIMULATED.
