//
//  ScanScreen.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI
import AVFoundation

struct ScanScreen: View {
    @ObservedObject var viewModel: ScanScreenViewModel
    @State private var status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    var body: some View {
        VStack(spacing: 16) {
            Eyebrow(text: "Scan a code")
            Text("Point at a TapCash QR").font(.title2.bold()).foregroundStyle(Palette.ink)

            switch status {
            case .authorized:
                QRScannerView { payload in viewModel.dispenseScanned(qrPayload: payload) }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if let scanError = viewModel.scanError {
                    Text(scanError).foregroundStyle(.red).multilineTextAlignment(.center)
                }
                if viewModel.loading { Text("Redeeming…").foregroundStyle(Palette.muted) }
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

            Button("Cancel") { viewModel.cancel() }
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
