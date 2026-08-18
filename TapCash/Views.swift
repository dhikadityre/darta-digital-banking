import SwiftUI
import AVFoundation
import UIKit

// MARK: - Root

struct RootView: View {
    @StateObject private var vm = WithdrawalViewModel()

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()
            switch vm.route {
            case .login:  LoginView(vm: vm)
            case .home:   HomeView(vm: vm)
            case .amount: AmountView(vm: vm)
            case .qr:     QRView(vm: vm)
            case .scan:   ScanView(vm: vm)
            case .result: ResultView(vm: vm)
            }
        }
        .animation(.easeInOut, value: vm.route)
    }
}

// MARK: - Login

struct LoginView: View {
    @ObservedObject var vm: WithdrawalViewModel
    @State private var email = "alex@tapcash.demo"
    @State private var password = "cash1234"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Eyebrow(text: "TapCash")
            Text("Cardless cash")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.ink)
            Text("Sign in to your SIMULATED account.")
                .foregroundStyle(Palette.muted)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = vm.errorMessage {
                Text(error).foregroundStyle(.red).font(.footnote)
            }

            Button(vm.loading ? "Signing in…" : "Sign in") {
                vm.login(email: email, password: password)
            }
            .buttonStyle(PrimaryButtonStyle(enabled: !vm.loading))
            .disabled(vm.loading)

            Spacer()
        }
        .padding(24)
    }
}

// MARK: - Home

struct HomeView: View {
    @ObservedObject var vm: WithdrawalViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Eyebrow(text: "Available balance")
            Text(vm.balanceCents.usd)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.ink)
            Text("Welcome back, \(vm.displayName ?? "there").")
                .foregroundStyle(Palette.muted)
            Spacer()
            Button("Withdraw cash") { vm.route = .amount }
                .buttonStyle(PrimaryButtonStyle())
            Button("Scan a code (ATM mode)") { vm.startScan() }
                .font(.headline)
                .foregroundStyle(Palette.navy)
                .frame(maxWidth: .infinity, minHeight: 52)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.navy, lineWidth: 1))
            Text("All funds are SIMULATED.")
                .font(.footnote).foregroundStyle(Palette.muted)
        }
        .padding(24)
    }
}

// MARK: - Limits card

struct LimitsCard: View {
    let limits: LimitsResponse
    private var fraction: Double {
        limits.dailyLimitCents == 0 ? 0 :
            min(1, Double(limits.withdrawnTodayCents) / Double(limits.dailyLimitCents))
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Eyebrow(text: "Withdrawal limits")
            row("Per transaction", "\(limits.minCents.usd) – \(limits.maxCents.usd)")
            row("Daily limit", limits.dailyLimitCents.usd)
            row("Used today", limits.withdrawnTodayCents.usd)
            ProgressView(value: fraction)
                .tint(Palette.orange)
            Text("\(limits.remainingTodayCents.usd) remaining today")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Palette.navy)
        }
        .padding(16)
        .background(Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(Palette.muted)
            Spacer()
            Text(value).fontWeight(.bold).foregroundStyle(Palette.ink)
        }
    }
}

// MARK: - Amount

struct AmountView: View {
    @ObservedObject var vm: WithdrawalViewModel
    @State private var selected = 4000
    private let options = [2000, 4000, 6000, 10000, 20000]

    private var maxAllowed: Int {
        min(vm.limits?.maxCents ?? 20000, vm.limits?.remainingTodayCents ?? .max)
    }
    private var minAllowed: Int { vm.limits?.minCents ?? 2000 }
    private var valid: Bool { selected >= minAllowed && selected <= maxAllowed }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Eyebrow(text: "Step 02 / Amount")
            Text("How much cash?")
                .font(.title.bold())
                .foregroundStyle(Palette.ink)

            if let limits = vm.limits { LimitsCard(limits: limits) }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(options, id: \.self) { amount in
                    Button {
                        selected = amount
                    } label: {
                        Text(amount.usd)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .foregroundStyle(selected == amount ? .white : Palette.navy)
                            .background(selected == amount ? Palette.navy : Palette.surface)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.navy, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(amount <= maxAllowed ? 1 : 0.4)
                    }
                    .disabled(amount > maxAllowed)
                }
            }

            if !valid {
                Text("Choose an amount within your remaining daily limit (\(maxAllowed.usd)).")
                    .foregroundStyle(.red).font(.footnote)
            }
            if let error = vm.errorMessage {
                Text(error).foregroundStyle(.red).font(.footnote)
            }

            Spacer()
            Button(vm.loading ? "Creating…" : "Create one-time QR") {
                vm.createWithdrawal(amountCents: selected)
            }
            .buttonStyle(PrimaryButtonStyle(enabled: !vm.loading && valid))
            .disabled(vm.loading || !valid)
        }
        .padding(24)
    }
}

// MARK: - QR (live countdown + auto-refresh)

struct QRView: View {
    @ObservedObject var vm: WithdrawalViewModel
    @State private var remaining = 0
    @State private var refreshed = false
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private static func secondsUntil(_ iso: String) -> Int {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
        guard let date else { return 0 }
        return max(0, Int(date.timeIntervalSinceNow))
    }

    var body: some View {
        VStack(spacing: 16) {
            if let ticket = vm.ticket {
                let expired = remaining <= 0
                Eyebrow(text: "Show this code at the ATM")
                Text(ticket.amountCents.usd)
                    .font(.system(size: 38, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink)

                ZStack {
                    if let image = QRCode.image(from: ticket.qrPayload) {
                        Image(uiImage: image)
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 240, height: 240)
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    if expired {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Palette.navy.opacity(0.94))
                            .frame(width: 272, height: 272)
                            .overlay(
                                VStack(spacing: 4) {
                                    Text("EXPIRED").foregroundStyle(.white).font(.headline).tracking(2)
                                    Text("Refreshing…").foregroundStyle(.white.opacity(0.8)).font(.caption)
                                }
                            )
                    }
                }

                Text(expired
                     ? "Codes expire for your safety — a fresh one is on the way."
                     : "Expires in \(timeString) · a new code refreshes automatically.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(expired ? .red : Palette.muted)

                Text("Txn \(ticket.transactionId.prefix(8))…")
                    .font(.footnote.monospaced())

                Spacer()
                Button("Refresh code now") { vm.refreshTicket() }
                    .buttonStyle(PrimaryButtonStyle())
                Button("Done") { vm.finish() }
                    .font(.headline).foregroundStyle(Palette.navy)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.navy, lineWidth: 1))
            }
        }
        .padding(24)
        .onAppear { syncRemaining() }
        .onChange(of: vm.ticket?.token) { _ in refreshed = false; syncRemaining() }
        .onReceive(tick) { _ in
            syncRemaining()
            if remaining <= 0 && !refreshed {
                refreshed = true
                vm.refreshTicket()
            }
        }
    }

    private var timeString: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    private func syncRemaining() {
        if let iso = vm.ticket?.expiresAt { remaining = Self.secondsUntil(iso) }
    }
}

// MARK: - Scan (ATM mode) with permission handling

struct ScanView: View {
    @ObservedObject var vm: WithdrawalViewModel
    @State private var status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    var body: some View {
        VStack(spacing: 16) {
            Eyebrow(text: "Scan a code")
            Text("Point at a TapCash QR").font(.title2.bold()).foregroundStyle(Palette.ink)

            switch status {
            case .authorized:
                QRScannerView { payload in vm.dispenseScanned(qrPayload: payload) }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if let scanError = vm.scanError {
                    Text(scanError).foregroundStyle(.red).multilineTextAlignment(.center)
                }
                if vm.loading { Text("Redeeming…").foregroundStyle(Palette.muted) }
            case .notDetermined:
                Spacer()
                Text("We use the camera only to scan a code.").foregroundStyle(Palette.muted)
                Button("Allow camera") { requestAccess() }.buttonStyle(PrimaryButtonStyle())
                Spacer()
            default: // denied / restricted
                Spacer()
                Text("Camera access is needed to scan. Enable it in Settings.")
                    .multilineTextAlignment(.center).foregroundStyle(Palette.muted)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }.buttonStyle(PrimaryButtonStyle())
                Spacer()
            }

            Button("Cancel") { vm.finish() }
                .font(.headline).foregroundStyle(Palette.navy)
                .frame(maxWidth: .infinity, minHeight: 52)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.navy, lineWidth: 1))
        }
        .padding(24)
        .onAppear { if status == .notDetermined { requestAccess() } }
    }

    private func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                status = granted ? .authorized : AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
}

// MARK: - Result

struct ResultView: View {
    @ObservedObject var vm: WithdrawalViewModel
    var body: some View {
        VStack(spacing: 14) {
            if let result = vm.dispenseResult {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56)).foregroundStyle(Palette.green)
                Eyebrow(text: "Withdrawal complete")
                Text("Cash dispensed").font(.title.bold()).foregroundStyle(Palette.ink)
                Text(result.amountCents.usd)
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink)
                Text("Remaining balance \(result.remainingBalanceCents.usd)")
                    .foregroundStyle(Palette.muted)
                Text("Txn \(result.transactionId.prefix(8))…").font(.footnote.monospaced())
                Spacer()
                Button("Done") { vm.finish() }.buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(24)
    }
}
