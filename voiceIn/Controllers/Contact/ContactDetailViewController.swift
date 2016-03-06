import UIKit
import Material

class ContactDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    var userInformation: [String: String?] = [String: String?]()
    
    private lazy var menuView: MenuView = MenuView()
    let spacing: CGFloat = 16
    let diameter: CGFloat = 56
    let height: CGFloat = 36
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: self-sizing cell setting.
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 70;
        prepareView()
        prepareMenuView()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! ContactDetailTableViewCell
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "姓名"
            cell.valueLabel.text = userInformation["userName"]!
        case 1:
            cell.fieldLabel.text = "公司"
            cell.valueLabel.text = userInformation["company"] != nil ? userInformation["company"]! as String! : "未設定"
        case 2:
            cell.fieldLabel.text = "職位"
            cell.valueLabel.text = userInformation["jobTitle"] != nil ? userInformation["jobTitle"]! as String! : "未設定"
        case 3:
            cell.fieldLabel.text = "暱稱"
            cell.valueLabel.text = userInformation["nickName"] != nil ? userInformation["nickName"]! as String! : "未設定"
        case 4:
            cell.fieldLabel.text = "關於"
            cell.valueLabel.text = userInformation["profile"] != nil ? userInformation["profile"]! as String! : "未設定"
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }

    // MARK: Handle the menuView touch event.
    internal func handleMenu() {
        if menuView.menu.opened {
            menuView.menu.close()
            (menuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(duration: 0))
        } else {
            menuView.menu.open() { (v: UIView) in
                (v as? MaterialButton)?.pulse()
            }
            (menuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(duration: 0.125))
        }
    }
    
    // MARK: Handle the menuView touch event.
    internal func handleButton(button: UIButton) {
        print("Hit Button \(button)")
    }
    
    // MARK: General preparation statements are placed here.
    private func prepareView() {
        view.backgroundColor = MaterialColor.white
    }
    
    // MARK: Prepares the MenuView example.
    private func prepareMenuView() {
        var image: UIImage? = UIImage(named: "ic_menu_white")?.imageWithRenderingMode(.AlwaysTemplate)
        let btn1: FabButton = FabButton()
        btn1.depth = .None
        btn1.tintColor = MaterialColor.blue.accent3
        btn1.pulseColor = nil
        btn1.borderColor = MaterialColor.blue.accent3
        btn1.backgroundColor = MaterialColor.white
        btn1.borderWidth = 1
        btn1.setImage(image, forState: .Normal)
        btn1.setImage(image, forState: .Highlighted)
        btn1.addTarget(self, action: "handleMenu", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn1)
        
        image = UIImage(named: "ic_call_white")?.imageWithRenderingMode(.AlwaysTemplate)
        let btn2: FabButton = FabButton()
        btn2.depth = .None
        btn2.tintColor = MaterialColor.blue.accent3
        btn2.pulseColor = MaterialColor.blue.accent3
        btn2.borderColor = MaterialColor.blue.accent3
        btn2.backgroundColor = MaterialColor.white
        btn2.borderWidth = 1
        btn2.setImage(image, forState: .Normal)
        btn2.setImage(image, forState: .Highlighted)
        btn2.addTarget(self, action: "handleButton:", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn2)
        
        image = UIImage(named: "ic_favorite_white")?.imageWithRenderingMode(.AlwaysTemplate)
        let btn3: FabButton = FabButton()
        btn3.depth = .None
        btn3.tintColor = MaterialColor.blue.accent3
        btn3.pulseColor = MaterialColor.blue.accent3
        btn3.borderColor = MaterialColor.blue.accent3
        btn3.backgroundColor = MaterialColor.white
        btn3.borderWidth = 1
        btn3.setImage(image, forState: .Normal)
        btn3.setImage(image, forState: .Highlighted)
        btn3.addTarget(self, action: "handleButton:", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn3)
        
        image = UIImage(named: "ic_delete_forever_white")?.imageWithRenderingMode(.AlwaysTemplate)
        let btn4: FabButton = FabButton()
        btn4.depth = .None
        btn4.tintColor = MaterialColor.blue.accent3
        btn4.pulseColor = MaterialColor.blue.accent3
        btn4.borderColor = MaterialColor.blue.accent3
        btn4.backgroundColor = MaterialColor.white
        btn4.borderWidth = 1
        btn4.setImage(image, forState: .Normal)
        btn4.setImage(image, forState: .Highlighted)
        btn4.addTarget(self, action: "handleButton:", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn4)
        
        // MARK: Initialize the menu and setup the configuration options.
        menuView.menu.direction = .Up
        menuView.menu.baseViewSize = CGSizeMake(diameter, diameter)
        menuView.menu.views = [btn1, btn2, btn3, btn4]
        
        view.addSubview(menuView)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.size(view, child: menuView, width: diameter, height: diameter)
        MaterialLayout.alignFromBottomLeft(view, child: menuView, bottom: 55, left: (view.bounds.width - diameter - 5))
    }
}
