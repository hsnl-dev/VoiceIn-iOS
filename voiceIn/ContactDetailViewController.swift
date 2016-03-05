import UIKit
import Material

class ContactDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    private lazy var menuView: MenuView = MenuView()
    let spacing: CGFloat = 16
    let diameter: CGFloat = 56
    let height: CGFloat = 36
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self-sizing cell setting.
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
            cell.valueLabel.text = "Calvin Jeng"
        case 1:
            cell.fieldLabel.text = "公司"
            cell.valueLabel.text = "High Speed Network Laboratory."
        case 2:
            cell.fieldLabel.text = "職位"
            cell.valueLabel.text = "學生"
        case 3:
            cell.fieldLabel.text = "暱稱"
            cell.valueLabel.text = "王大明"
        case 4:
            cell.fieldLabel.text = "關於"
            cell.valueLabel.text = "標性以白相走從電……主散畫的。存濟空是沒的出公鄉有連家力字了會冷原空：飛只用太……世因務分義民頭政這們洲……完預不女，喜育作山運國照家歌體子，力了後站難的近十，色一很情他觀爾維究多對各開量方說落相為同女中見白這力學業嗎媽民畫來為，門的長些有他講了老充吃綠重行子化可天願問！隨況麼級學：馬單結市領地開眼力的上變月學值健人，主歡人。報失麼己度是品出黨發手斷媽局話士向放行交外趣時族一衣收反，保命更出論分行中險走應：痛水得主為手氣一問斯出過那個的回病雖斯活水，每能利從心長是，香產的原是，亮都古庭轉的小們工不世我綠頭其們讓手，水原在日頭讀物。"
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }

    /// Handle the menuView touch event.
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
    
    /// Handle the menuView touch event.
    internal func handleButton(button: UIButton) {
        print("Hit Button \(button)")
    }
    
    /// General preparation statements are placed here.
    private func prepareView() {
        view.backgroundColor = MaterialColor.white
    }
    
    /// Prepares the MenuView example.
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
        
        // Initialize the menu and setup the configuration options.
        menuView.menu.direction = .Up
        menuView.menu.baseViewSize = CGSizeMake(diameter, diameter)
        menuView.menu.views = [btn1, btn2, btn3, btn4]
        
        view.addSubview(menuView)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.size(view, child: menuView, width: diameter, height: diameter)
        MaterialLayout.alignFromBottomLeft(view, child: menuView, bottom: 55, left: (view.bounds.width - diameter))
    }
}
