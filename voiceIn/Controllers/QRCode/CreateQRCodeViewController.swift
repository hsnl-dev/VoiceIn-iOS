import UIKit
import Alamofire

class CreateQRCodeViewController: UITableViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let headers = Network.generateHeader(isTokenNeeded: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createCustomQrCode(sender: UIButton!) {
        let userUuid = userDefaultData.stringForKey("userUuid")!
        let createCustomQrCodeRoute = API_END_POINT + "/accounts/" + userUuid + "/customQrcodes"
        let parameters = [
            "name": userNameTextField.text as! AnyObject,
            "phoneNumber": phoneNumberTextField.text as! AnyObject,
            "company": companyTextField.text as! AnyObject
        ]
        
        Alamofire.request(.POST, createCustomQrCodeRoute, parameters: parameters, encoding: .JSON,
            headers: headers
            ).response {
                request, response, data, error in
                if error == nil {
                    debugPrint(response)
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    //MARK: TODO Error handling
                    debugPrint(error)
                }
        }
    }
    
}
