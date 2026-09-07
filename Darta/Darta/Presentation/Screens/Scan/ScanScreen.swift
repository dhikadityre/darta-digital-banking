//
//  ScanScreen.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI
import AVFoundation

struct ScanScreen: View {
    @ObservedObject var viewModel: ScanScreenViewModel
    @State private var status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header
            VStack(spacing: 6) {
                EyebrowView(text: "Cashier Mode", iconName: "camera.viewfinder")

                Text("Scan Customer QR")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.ink)

                Text("Align customer's QR code within the frame to dispense cash.")
                    .font(.caption)
                    .foregroundStyle(Palette.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            // MARK: - Scanner Area / Camera State
            switch status {
            case .authorized:
                ZStack {
                    QRScannerView { payload in
                        viewModel.dispenseScanned(qrPayload: payload)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Palette.amber.opacity(0.4), lineWidth: 1.5)
                    )

                    // Scanner Target Corner Reticle Overlays
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Palette.amber, Palette.amber.opacity(0.3), Palette.amber],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [35, 120])
                        )
                        .padding(24)

                    if viewModel.loading {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Palette.canvas.opacity(0.85))

                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(Palette.amber)
                                    .scaleEffect(1.3)

                                Text("Verifying & Dispensing…")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Palette.ink)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 8)

                if let scanError = viewModel.scanError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Palette.red)
                        Text(scanError)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Palette.red)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Palette.red.opacity(0.12))
                    )
                }

            case .notDetermined:
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Palette.amber)

                    Text("Camera Access Required")
                        .font(.headline)
                        .foregroundStyle(Palette.ink)

                    Text("We use the camera exclusively to scan customer withdrawal tickets.")
                        .font(.footnote)
                        .foregroundStyle(Palette.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Button("Allow Camera Access") {
                        requestAccess()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Palette.surface)
                )
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Palette.border, lineWidth: 1))
                Spacer()

            default:
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "camera.badge.ellipsis")
                        .font(.system(size: 48))
                        .foregroundStyle(Palette.amber)

                    Text("Camera Permission Denied")
                        .font(.headline)
                        .foregroundStyle(Palette.ink)

                    Text("Enable camera access in Settings to use cashier scan mode.")
                        .font(.footnote)
                        .foregroundStyle(Palette.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Palette.surface)
                )
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Palette.border, lineWidth: 1))
                Spacer()
            }

            // MARK: - Cancel Button
            Button("Cancel") {
                viewModel.cancel()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(20)
        .background(
            ZStack {
                Palette.canvas.ignoresSafeArea()
                Palette.radialAmbient.ignoresSafeArea()
            }
        )
        .onAppear {
            if status == .notDetermined {
                requestAccess()
            }
        }
    }

    private func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                status = granted ? .authorized : AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
}
