import SwiftUI
import AVFoundation

/// SwiftUI wrapper around an AVCaptureSession that reports decoded QR strings.
struct QRScannerView: UIViewControllerRepresentable {
    let onDecoded: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onDecoded: onDecoded) }

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onDecoded: (String) -> Void

        init(onDecoded: @escaping (String) -> Void) { self.onDecoded = onDecoded }

        /*
        /// Only Running 1 time
        private var handled = false
        
        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard !handled,
                  let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = obj.stringValue,
                  value.hasPrefix("TC1.") else { return }
            handled = true
            onDecoded(value)
        }
        */
        
        /// Can Running Multiple Time
        private var lastPayload: String?
        private var lastScanTime: Date?
        
        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard
                let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                let value = obj.stringValue,
                value.hasPrefix("TC1.")
            else { return }
            
            if value == lastPayload, let lastTime = lastScanTime, Date().timeIntervalSince(lastTime) < 3.0 {
                return
            }
            
            lastPayload = value
            lastScanTime = Date()
            onDecoded(value)
        }
    }
}

/// Minimal camera preview controller configured for QR metadata.
final class ScannerViewController: UIViewController {
    weak var delegate: AVCaptureMetadataOutputObjectsDelegate?
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSession()
    }

    private func configureSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(delegate, queue: .main)
        output.metadataObjectTypes = [.qr]

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        previewLayer = layer

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if session.isRunning { session.stopRunning() }
    }
}
