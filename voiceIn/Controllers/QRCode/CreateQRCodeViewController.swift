import UIKit
import Alamofire
import AddressBook
import AddressBookUI
import PhoneNumberKit

class CreateQRCodeViewController: UITableViewController, ABPeoplePickerNavigationControllerDelegate {
    let headers = Network.generateHeader(isTokenNeeded: true)
    var personPicker: ABPeoplePickerNavigationController
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    var phoneNumberText: String?
    
    required init(coder aDecoder: NSCoder) {
        personPicker = ABPeoplePickerNavigationController()
        super.init(coder: aDecoder)!
        personPicker.peoplePickerDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController){
        /* Mandatory to implement */
    }
    
    func peoplePickerNavigationController(
        peoplePicker: ABPeoplePickerNavigationController,
        didSelectPerson person: ABRecordRef){
        
        if peoplePicker != personPicker{
            return
        }
        
        let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty)?
            .takeRetainedValue() as! String? ?? ""
        
        let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty)?
            .takeRetainedValue() as! String? ?? ""
        
        userNameTextField.text = lastName + firstName
        
        let _ = ABRecordCopyValue(person, kABPersonNicknameProperty)?
            .takeRetainedValue() as! String? ?? ""
        
        let organization = ABRecordCopyValue(person, kABPersonOrganizationProperty)?
            .takeRetainedValue() as! String? ?? ""
        companyTextField.text = organization
        
        let phoneValuesProperty = ABRecordCopyValue(person, kABPersonPhoneProperty)
        if phoneValuesProperty != nil {
            let phoneValues: ABMutableMultiValueRef? = phoneValuesProperty.takeRetainedValue()
            if phoneValues != nil {
                for i in 0 ..< ABMultiValueGetCount(phoneValues){
                    let phoneLabel = ABMultiValueCopyLabelAtIndex(phoneValues, i).takeRetainedValue()
                        as CFStringRef as CFString;
                    if phoneLabel == kABPersonPhoneMobileLabel {
                        
                        let value = ABMultiValueCopyValueAtIndex(phoneValues, i)
                        let phone = (value.takeRetainedValue() as! String).stringByReplacingOccurrencesOfString("-", withString: "")
                        do {
                            debugPrint(phone)
                            let formatedPhone = try PhoneNumber(rawNumber: phone, region: "TW")
                            phoneNumberTextField.text = formatedPhone.toNational()
                            phoneNumberText = formatedPhone.toE164()
                        }
                        catch {
                            print("Generic parser error")
                            AlertBox.createAlertView(self, title: "注意", body: "請輸入正確台灣手機電話格式喔!", buttonValue: "確認")
                            return
                        }
                    }
                }
            }
        }
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, shouldContinueAfterSelectingPerson person: ABRecordRef) -> Bool {
        
        peoplePickerNavigationController(peoplePicker, didSelectPerson: person)
        
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
        
        return false;
    }
    
    @IBAction func performPickPerson(sender : AnyObject) {
        self.presentViewController(personPicker, animated: true, completion: nil)
    }
    
    @IBAction func createCustomQrCode(sender: UIButton!) {
        let userUuid = UserPref.getUserPrefByKey("userUuid")
        let createCustomQrCodeRoute = API_END_POINT + "/accounts/" + userUuid! + "/customQrcodes"
        
        if userNameTextField.text! == "" || phoneNumberTextField.text! == "" {
            AlertBox.createAlertView(self, title: "注意", body: "姓名和電話都要填寫喔", buttonValue: "確認")
            return
        }
        
        debugPrint("phoneNumberTextField \(phoneNumberTextField.text!) userNameTextField \(userNameTextField.text!)")
        
        // MARK - Manual input.
        if phoneNumberText == nil && phoneNumberTextField.text != nil {
            do {
                let formatedPhone = try PhoneNumber(rawNumber: phoneNumberTextField.text!, region: "TW")
                phoneNumberText = formatedPhone.toE164()
            }
            catch {
                AlertBox.createAlertView(self, title: "注意", body: "請輸入正確台灣手機電話格式喔!", buttonValue: "確認")
                print("Generic parser error")
                return
            }
        }
        
        let parameters = [
            "name": userNameTextField.text as! AnyObject,
            "phoneNumber": phoneNumberText as! AnyObject,
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
                    AlertBox.createAlertView(self, title: "抱歉..", body: "可能為網路或伺服器錯誤，請等一下再試", buttonValue: "確認")
                }
        }
    }
}