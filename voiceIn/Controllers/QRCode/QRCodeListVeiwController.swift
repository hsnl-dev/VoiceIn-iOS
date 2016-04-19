import UIKit
import Alamofire
import SwiftyJSON
import SwiftOverlays

class QRCodeListVeiwController: UITableViewController {
    var qrCodeList: [QRCode] = [QRCode]()
    let headers = Network.generateHeader(isTokenNeeded: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        getQrCodeList()
    }
    
    // MARK: Trigger when user selected the row.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let qrCodeLink = QRCODE_ROUTE + (tableView.cellForRowAtIndexPath(indexPath) as! QrCodeListCell).qrCodeUuid
        let defaultText = "這是給您的專屬 QRCode，請掃描加入我，或點以下連結加入我\n \(qrCodeLink)"
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! QrCodeListCell
        let getQrCodeApiRoute = API_END_POINT + "/qrcodes/" + cell.qrCodeUuid! + "/image"
        
        // MARK: Sharing the custom QRCode
        Alamofire
            .request(.GET, getQrCodeApiRoute, headers: self.headers)
            .responseData {
                response in
    
                if response.response?.statusCode == 200 && response.data != nil {
                    let imageToShare: UIImage = UIImage(data: response.data!)!
                    let activityController = UIActivityViewController(activityItems:[defaultText, imageToShare], applicationActivities: nil)
                    self.presentViewController(activityController, animated: true,completion: nil)
                } else {
                    //MARK: TODO Error handling
                    debugPrint(response)
                    self.createAlertView("抱歉..", body: "可能為網路或伺服器錯誤，請等一下再試", buttonValue: "確認")
                }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: How many row in a section.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qrCodeList.count
    }
    
    // MARK: Show QRCode List.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "qrCodeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! QrCodeListCell
        
        cell.company.text = self.qrCodeList[indexPath.row].company
        cell.nameLabel.text = self.qrCodeList[indexPath.row].name
        cell.phoneNumberLabel.text = self.qrCodeList[indexPath.row].phoneNumber
        cell.qrCodeUuid = self.qrCodeList[indexPath.row].qrCodeUuid
        cell.qrCodeImage.image = UIImage(CIImage: (QRCodeGenerator.generateQRCodeImage(qrCodeString: QRCODE_ROUTE + self.qrCodeList[indexPath.row].qrCodeUuid)))
        
        return cell
    }
    
    //MARK: Delete the Custom QRCode
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath) {
        
        // Delete the created customed QRCode.
        if editingStyle == .Delete {
            let deleteAlert = UIAlertController(title: "注意!", message: "確定要刪除此筆聯絡人?", preferredStyle: UIAlertControllerStyle.Alert)
            
            deleteAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: {action in
                print("deleting...")
                let text = "刪除中..."
                self.showWaitOverlayWithText(text)
                
                let deleteApiRoute = API_END_POINT + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/customQrcodes/" + (tableView.cellForRowAtIndexPath(indexPath) as! QrCodeListCell).qrCodeUuid!
                
                Alamofire.request(.DELETE, deleteApiRoute, encoding: .JSON, headers: self.headers).response {
                    request, response, data, error in
                    if error == nil {
                        debugPrint(error)
                        self.tableView.beginUpdates()
                        self.removeAllOverlays()
                        self.qrCodeList.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        self.tableView.endUpdates()
                    } else {
                        //MARK: TODO Error handling
                        self.removeAllOverlays()
                        self.createAlertView("抱歉..", body: "可能為網路或伺服器錯誤，請等一下再試", buttonValue: "確認")
                    }
                }
            }))
            
            self.presentViewController(deleteAlert, animated: true, completion: nil)
        }
    }
    
    
    func getQrCodeList() {
        let getInformationApiRoute = API_END_POINT + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/customQrcodes"
        
        self.tableView.reloadData()
        self.showWaitOverlay()
        self.view.userInteractionEnabled = false
        
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    var jsonResponse = JSON(JSON_RESPONSE)
                    jsonResponse = jsonResponse["qrcodes"]
                    self.qrCodeList = []
                    
                    for var index = jsonResponse.count - 1; index >= 0; --index {
                        var qrCodeInformation = jsonResponse[index]
                        var qrCode: QRCode!
                        let userName = qrCodeInformation["userName"].stringValue
                        let phoneNumber = qrCodeInformation["phoneNumber"].stringValue
                        let qrCodeUuid = qrCodeInformation["id"].stringValue
                        qrCode = QRCode(company: "未設定公司", name: userName, phoneNumber: phoneNumber, qrCodeUuid: qrCodeUuid)
                        self.qrCodeList.append(qrCode)
                    }
                    
                    self.tableView.reloadData()
                case .Failure(let error):
                    //MARK: TODO Error handling
                    debugPrint(error)
                    self.createAlertView("抱歉..", body: "可能為網路或伺服器錯誤，請等一下再試", buttonValue: "確認")
                }
                
                self.removeAllOverlays()
                self.view.userInteractionEnabled = true
                self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func closeCreateQRCode(segue: UIStoryboardSegue) {
        debugPrint("closeCreateQRCode Modal")
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
