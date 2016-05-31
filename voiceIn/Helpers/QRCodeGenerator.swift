import Foundation
import UIKit

class QRCodeGenerator {
    
    class func generateQRCodeImage(qrCodeString qrCodeString: String) -> CIImage {
        let qrCodeData = qrCodeString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        var qrcodeImage: CIImage!
        // MARK: Generate the QRCode
        filter!.setValue(qrCodeData, forKey: "inputMessage")
        filter!.setValue("H", forKey: "inputCorrectionLevel")
        
        qrcodeImage = filter!.outputImage
        return qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(125, 125))
    }
    
}