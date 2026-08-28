import Foundation
import CoreImage.CIFilterBuiltins
import UIKit

/// Renders the server-signed QR payload string into a crisp UIImage using CoreImage.
enum QRCode {
    static func image(from payload: String, scale: CGFloat = 10) -> UIImage? {
        let context = CIContext()
        // MARK: - STEP 5.0
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = "M"

        guard let output = filter.outputImage?
            .transformed(by: CGAffineTransform(scaleX: scale, y: scale)),
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
