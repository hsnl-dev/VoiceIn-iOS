import UIKit
import Alamofire
import SwiftyJSON
import Material
import SwiftOverlays

class vCardViewController: UIViewController {

    let headers = Network.generateHeader(isTokenNeeded: true)
    let cardView: CardView = CardView()
    let imageCardView: ImageCardView = ImageCardView()

    var scrollView: UIScrollView!
    var qrCodeLink: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = MaterialColor.grey.lighten3
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(scrollView)
        prepareGenQrCodeCardView()
        
        self.navigationController?.view.userInteractionEnabled = false
        SwiftOverlays.showCenteredWaitOverlayWithText(self.view, text: "讀取名片中...")
        let getInformationApiRoute = API_END_POINT + "/accounts/" + UserPref.getUserPrefByKey("userUuid")!
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
                    self.prepareVcardView(jsonResponse)
                case .Failure(let error):
                    AlertBox.createAlertView(self, title: "抱歉..", body: "可能為網路或伺服器錯誤，請等一下再試", buttonValue: "確認")
                    debugPrint(error)
                }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = UIScreen.mainScreen().bounds.size
        scrollView.contentSize.height = imageCardView.height + cardView.height + 25
    }
    
    private func prepareVcardView(jsonResponse: JSON) {
        let getImageApiRoute = API_END_POINT + "/avatars/" + jsonResponse["profilePhotoId"].stringValue
        imageCardView.maxImageHeight = 150
        
        // Image.
        let size: CGSize = CGSizeMake(MaterialDevice.width - CGFloat(40), 150)
        imageCardView.image = UIImage(named: "blurred-web-backgrounds.jpg")
        
        // Title label.
        let titleLabel: UILabel = UILabel()
        titleLabel.text = jsonResponse["userName"].stringValue
        titleLabel.textColor = MaterialColor.white
        titleLabel.font = RobotoFont.mediumWithSize(24)
        imageCardView.titleLabel = titleLabel
        imageCardView.titleLabelInset.top = 100
        
        // Detail label.
        let detailLabel: UILabel = UILabel()
        detailLabel.text = "職稱: \(jsonResponse["jobTitle"].stringValue == "" ? "尚未填寫職位" : jsonResponse["jobTitle"].stringValue) \n連絡信箱: \(jsonResponse["email"].stringValue == "" ? "尚未填寫聯絡方式" : jsonResponse["email"].stringValue)\n\n關於: \n \(jsonResponse["profile"].stringValue.trim() == "" ? "尚未填寫介紹" : jsonResponse["profile"].stringValue.trim())\n\n來自於: \(jsonResponse["location"].stringValue == "" ? "未填寫地址" : jsonResponse["location"].stringValue)"
        detailLabel.numberOfLines = 0
        imageCardView.detailView = detailLabel
        
        
        if jsonResponse["profilePhotoId"].stringValue != "" {
            // MARK: Retrieve the image
            let avatarView: UIImageView = UIImageView()
            let qrCodeView: UIImageView = UIImageView()

            Alamofire
                .request(.GET, getImageApiRoute, headers: self.headers, parameters: ["size": "mid"])
                .responseData {
                    response in
                    // MARK: TODO Error handling
                    
                    qrCodeView.frame = CGRect(x: self.imageCardView.frame.origin.x + self.imageCardView.width - 110 , y: 5, width: 100, height: 100)
                    qrCodeView.image = UIImage(CIImage: (QRCodeGenerator.generateQRCodeImage(qrCodeString: QRCODE_ROUTE + jsonResponse["qrCodeUuid"].stringValue)))
                    
                    self.imageCardView.addSubview(qrCodeView)
                    self.imageCardView.bringSubviewToFront(qrCodeView)
                    self.qrCodeLink = QRCODE_ROUTE + jsonResponse["qrCodeUuid"].stringValue
                    
                    if response.data != nil {
                        avatarView.image = UIImage(data: response.data!)
                        self.imageCardView.addSubview(avatarView)
                        avatarView.frame = CGRect(x: 5, y: 5, width: 100, height: 100)
                        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2;
                        avatarView.clipsToBounds = true;
                        
                        self.navigationController?.view.userInteractionEnabled = true
                        SwiftOverlays.removeAllOverlaysFromView(self.view!)
                    }
            }
            
        } else {
            SwiftOverlays.removeAllOverlaysFromView(self.view!)
        }
        
        
        let btn1: FlatButton = FlatButton()
        btn1.pulseColor = MaterialColor.cyan.lighten1
        btn1.pulseScale = false
        btn1.setTitle(jsonResponse["company"].stringValue == "" ? "尚未填寫公司" : jsonResponse["company"].stringValue, forState: .Normal)
        btn1.setTitleColor(MaterialColor.cyan.darken1, forState: .Normal)
        
        // Add buttons to left side.
        imageCardView.leftButtons = [btn1]
        
        // To support orientation changes, use MaterialLayout.
        scrollView.addSubview(imageCardView)
        imageCardView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.alignFromTop(scrollView, child: imageCardView, top: 200)
        MaterialLayout.alignFromLeft(scrollView, child: imageCardView, left: 5)
        MaterialLayout.width(scrollView, child: imageCardView, width: scrollView.bounds.width - 10)
    }
    
    func prepareGenQrCodeCardView() {
        
        // Title label.
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "專屬特製 QRCode"
        titleLabel.textColor = MaterialColor.blue.darken1
        titleLabel.font = RobotoFont.mediumWithSize(15)
        cardView.titleLabel = titleLabel
        
        // Detail label.
        let detailLabel: UILabel = UILabel()
        detailLabel.text = "點此為您的朋友建立專屬的 QRCode，朋友即可不入輸入任何資料即可掃瞄建立聯絡 icon。"
        detailLabel.numberOfLines = 0
        cardView.detailView = detailLabel
        
        // Yes button.
        let btn1: FlatButton = FlatButton()
        btn1.pulseColor = MaterialColor.cyan.lighten1
        btn1.pulseScale = false
        btn1.setTitle("點我製作專屬 QRCode", forState: .Normal)
        btn1.setTitleColor(MaterialColor.cyan.darken1, forState: .Normal)
        cardView.leftButtons = [btn1]
        
        let gesture = UITapGestureRecognizer(target: self, action: "performSegue:")
        cardView.addGestureRecognizer(gesture)
        
        // To support orientation changes, use MaterialLayout.
        scrollView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.alignFromTop(scrollView, child: cardView, top: 10)
        MaterialLayout.alignFromLeft(scrollView, child: cardView, left: 5)
        MaterialLayout.width(scrollView, child: cardView, width: scrollView.bounds.width - 10)

    }
    
    func performSegue(sender: AnyObject) {
        performSegueWithIdentifier("showGenQrCodeSegue", sender: nil)
    }
    
    @IBAction func shareQRCodeButtonClicked(sender: UIButton!) {
        let defaultText = "這是我的 VoiceIn QR Code 名片，請掃描 QRCode 或點以下連結加入我\n \(qrCodeLink)"
        
        if let imageToShare: UIImage! = self.imageCardView.toImage() {
            let activityController = UIActivityViewController(activityItems:[defaultText, imageToShare], applicationActivities: nil)
            self.presentViewController(activityController, animated: true,completion: nil)
        }
    }
    
    @IBAction func closeQRCodeList(segue: UIStoryboardSegue) {
        
    }
}