import UIKit
import Alamofire
import SwiftyJSON

class vCardViewController: UIViewController {
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let headers = Network.generateHeader(isTokenNeeded: true)
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var profile: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let getInformationApiRoute = API_END_POINT + "/accounts/" + userDefaultData.stringForKey("userUuid")!
        /**
        GET: Get the user's information.
        **/
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    let getImageApiRoute = API_END_POINT + "/avatars/" + jsonResponse["profilePhotoId"].stringValue
                    
                    self.userName.text = jsonResponse["userName"].stringValue
                    self.company.text = jsonResponse["company"].stringValue
                    self.profile.text = jsonResponse["profile"].stringValue
                    self.location.text = jsonResponse["location"].stringValue
                    self.profile.sizeToFit()
                    
                    // MARK: Retrieve the image
                    Alamofire
                        .request(.GET, getImageApiRoute, headers: self.headers, parameters: ["size": "mid"])
                        .responseData {
                            response in
                            if response.data != nil {
                                self.userAvatar.image = UIImage(data: response.data!)
                            }
                    }
                    
                    self.generateQRCodeImage(qrCodeString: jsonResponse["qrCodeUuid"].stringValue)
                    
                case .Failure(let error):
                    self.createAlertView("抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                    debugPrint(error)
                }
        }
    }
    
    private func generateQRCodeImage(qrCodeString qrCodeString: String) {
        let qrCodeData = qrCodeString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        var qrcodeImage: CIImage!
        // MARK: Generate the QRCode
        filter!.setValue(qrCodeData, forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrcodeImage = filter!.outputImage
        let transformedImage = qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(125, 125))
        self.qrCodeImage.image = UIImage(CIImage: transformedImage)
        
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}