import UIKit
import Eureka
import Material
import Alamofire
import SwiftyJSON

class SettingViewController: FormViewController {
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    // MARK: The API Information.
    
    private var navigationBarView: NavigationBarView = NavigationBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareInputForm()
        prepareNavigationBar()
    }
    
    func prepareInputForm() {
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 32
            cell.accessoryView?.frame = CGRectMake(0, 0, 64, 64)
        }
        
        form +++
            Section(header: "基本資料", footer: "* 記號表示為必填")
            <<< ImageRow(){
                $0.title = "您的大頭貼"
                $0.cell.height = {
                    let height: CGFloat = 70.0
                    return height
                }
            }
            
            <<< NameRow() {
                $0.title = "您的姓名*:"
                $0.placeholder = ""
                $0.tag = "userName"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            <<< NameRow() {
                $0.title = "您的職稱:"
                $0.placeholder = ""
                $0.tag = "jobTitle"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            <<< NameRow() {
                $0.title = "所屬公司:"
                $0.placeholder = ""
                $0.tag = "company"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            <<< EmailRow() {
                $0.title = "您的信箱"
                $0.value = ""
                $0.tag = "email"
            }
            
            <<< NameRow() {
                $0.title = "位置:"
                $0.placeholder = "台北, 台灣"
                $0.tag = "location"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            +++ Section(header: "方便通話時段", footer: "您可以隨時設定您方便的通話同段")
            
            <<< TimeInlineRow(){
                $0.title = "開始時間"
                $0.value = NSDate()
                $0.tag = "availableStartTime"
            }
            
            <<< TimeInlineRow(){
                $0.title = "結束時間"
                $0.value = NSDate()
                $0.tag = "availableEndTime"
            }
            
            +++ Section("關於您")
            
            <<< TextAreaRow() {
                $0.placeholder = "介紹您自己，讓大家更能夠瞭解您。"
                $0.tag = "profile"
        }
    }
    
    func prepareNavigationBar() {
        // Title label.
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "您的個人資料"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = MaterialColor.white
        titleLabel.font = RobotoFont.regularWithSize(17)
        
        // Search button.
        let image = UIImage(named: "ic_save_white")
        let saveButton: FlatButton = FlatButton()
        saveButton.pulseColor = MaterialColor.white
        saveButton.pulseScale = false
        saveButton.setImage(image, forState: .Normal)
        saveButton.setImage(image, forState: .Highlighted)
        saveButton.addTarget(self, action: "saveButtonClicked:", forControlEvents: .TouchUpInside)
        
        navigationBarView.statusBarStyle = .LightContent
        navigationBarView.backgroundColor = MaterialColor.blue.base
        navigationBarView.titleLabel = titleLabel
        navigationBarView.rightControls = [saveButton]
        
        view.addSubview(navigationBarView)
    }
    
    func saveButtonClicked(sender: UIButton!) {
        let contactTableView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabViewController") as! UITabBarController
        let headers = Network.generateHeader(isTokenNeeded: true)
        let formValues = form.values()
        
        if formValues["userName"] as? String == nil {
            let alert = UIAlertController(title: "小提醒", message: "請輸入您的大名喔", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let availableStartTime: NSDate! = formValues["availableStartTime"] as? NSDate
        let availableEndTime: NSDate! = formValues["availableEndTime"] as? NSDate
        
        if (availableStartTime.isGreaterThanDate(availableEndTime)) {
            let alert = UIAlertController(title: "小提醒", message: "你所選定的時間區間不合理喔", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "H:mm"
        
        let parameters = [
            "userName": formValues["userName"] as? String != nil ? formValues["userName"] as? String : "",
            "profile": formValues["profile"] as? String != nil ? formValues["profile"] as? String : "",
            "location": formValues["location"] as? String != nil ? formValues["location"] as? String : "",
            "company": formValues["company"] as? String != nil ? formValues["company"] as? String : "",
            "availableStartTime": dateFormatter.stringFromDate((formValues["availableStartTime"] as? NSDate)!),
            "availableEndTime": dateFormatter.stringFromDate((formValues["availableEndTime"] as? NSDate)!),
            "phoneNumber": userDefaultData.stringForKey("phoneNumber") as String!
        ]
        
        let apiRoute = API_END_POINT + "/accounts/" + userDefaultData.stringForKey("userUuid")!
        
        print("PUT: " + apiRoute)
        
        Alamofire
            .request(.PUT, apiRoute, parameters: parameters, encoding: .JSON, headers: headers)
            .validate()
            .response { request, response, data, error in
                if error == nil {
                    //MARK: all is well!
                    self.presentViewController(contactTableView, animated: true, completion: nil)
                }
        }
    }
}
