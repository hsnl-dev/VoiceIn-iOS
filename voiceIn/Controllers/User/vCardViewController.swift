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
    @IBOutlet weak var cardView: UIView!
    
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
                            // MARK: TODO Error handling
                            if response.data != nil {
                                self.userAvatar.image = UIImage(data: response.data!)
                            }
                    }
                    
                    self.qrCodeImage.image = UIImage(CIImage: (QRCodeGenerator.generateQRCodeImage(qrCodeString: QRCODE_ROUTE + jsonResponse["qrCodeUuid"].stringValue)))
                    
                case .Failure(let error):
                    self.createAlertView("抱歉..", body: "可能為網路或伺服器錯誤，請等一下再試", buttonValue: "確認")
                    debugPrint(error)
                }
        }
    }
    
    @IBAction func shareQRCodeButtonClicked(sender: UIButton!) {
        let defaultText = "這是我的 VoiceIn QR Code 名片"
        
        if let imageToShare: UIImage! = self.cardView.image() {
            let activityController = UIActivityViewController(activityItems:[defaultText, imageToShare], applicationActivities: nil)
            self.presentViewController(activityController, animated: true,completion: nil)
        }
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func closeQRCodeList(segue: UIStoryboardSegue) {
        
    }
}