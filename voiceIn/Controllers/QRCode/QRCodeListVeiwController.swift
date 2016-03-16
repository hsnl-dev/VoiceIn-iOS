import UIKit
import Alamofire
import SwiftyJSON
import SwiftOverlays

class QRCodeListVeiwController: UITableViewController {
    var qrCodeList: [QRCode] = [QRCode]()
    let headers = Network.generateHeader(isTokenNeeded: true)
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getQrCodeList()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        getQrCodeList()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let defaultText = "這是給您的專屬 QRCode，請掃描加入我"
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! QrCodeListCell
        let getQrCodeApiRoute = API_END_POINT + "/qrcodes/" + cell.qrCodeUuid! + "/image"
        
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
                }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qrCodeList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "qrCodeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! QrCodeListCell
        
        cell.company.text = self.qrCodeList[indexPath.row].company
        cell.nameLabel.text = self.qrCodeList[indexPath.row].name
        cell.phoneNumberLabel.text = self.qrCodeList[indexPath.row].phoneNumber
        cell.qrCodeUuid = self.qrCodeList[indexPath.row].qrCodeUuid
        cell.qrCodeImage.image = UIImage(CIImage: (QRCodeGenerator.generateQRCodeImage(qrCodeString: self.qrCodeList[indexPath.row].qrCodeUuid)))
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath) {
        if editingStyle == .Delete {
            let deleteAlert = UIAlertController(title: "注意!", message: "確定要刪除此筆聯絡人?", preferredStyle: UIAlertControllerStyle.Alert)
            
            deleteAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: {action in
                print("deleting...")
                let text = "刪除中..."
                self.showWaitOverlayWithText(text)
                
                let deleteApiRoute = API_END_POINT + "/accounts/" + self.userDefaultData.stringForKey("userUuid")! + "/customQrcodes/" + (tableView.cellForRowAtIndexPath(indexPath) as! QrCodeListCell).qrCodeUuid!
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
                    }
                }
            }))
            
            self.presentViewController(deleteAlert, animated: true, completion: nil)
        }
    }
    
    
    func getQrCodeList() {
        self.view.userInteractionEnabled = false
        let getInformationApiRoute = API_END_POINT + "/accounts/" + userDefaultData.stringForKey("userUuid")! + "/customQrcodes"
        
        self.tableView.reloadData()
        self.showWaitOverlay()
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
                }
                
                self.removeAllOverlays()
                self.view.userInteractionEnabled = true
                self.refreshControl?.endRefreshing()
        }
    }
    
    func refresh(sender: AnyObject) {
        var reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            debugPrint("Unable to create Reachability")
            return
        }
        
        if reachability.isReachable() != true {
            debugPrint("Network is not connected!")
            // MARK: TODO Error handling
            self.refreshControl?.endRefreshing()
            self.view.userInteractionEnabled = true
        } else {
            getQrCodeList()
        }
    }
    
    @IBAction func closeCreateQRCode(segue: UIStoryboardSegue) {
        debugPrint("closeCreateQRCode Modal")
    }
}
