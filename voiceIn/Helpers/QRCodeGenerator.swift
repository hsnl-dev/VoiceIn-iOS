import Foundation
import UIKit

class QRCodeGenerator {
    class func generateQRCodeImage(qrCodeString qrCodeString: String) -> CIImage {
        let qrCodeData = qrCodeString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        var qrcodeImage: CIImage!
        // MARK: Generate the QRCode
        filter!.setValue(qrCodeData, forKey: "inputMessage")
        filter!.setValue("L", forKey: "inputCorrectionLevel")
        
        qrcodeImage = filter!.outputImage
        return qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(125, 125))
    }
    
}