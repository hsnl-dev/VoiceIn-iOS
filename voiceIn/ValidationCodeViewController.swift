import UIKit
import Material

class ValidationCodeViewController: UIViewController {
    @IBOutlet weak var validationCodeField: UITextField!
    @IBOutlet weak var checkValidationButton: RaisedButton!
    @IBOutlet weak var backButton: FabButton!
    @IBOutlet var backgroundImageView:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MaterialColor.white
        
        prepareButton()
        prepareField()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)

    }
    
    private func prepareButton() {
        checkValidationButton.setTitle("確認", forState: .Normal)
        checkValidationButton.titleLabel!.font = RobotoFont.mediumWithSize(15)
        
        let backImage: UIImage? = UIImage(named: "ic_arrow_back_white")
        self.backButton.setImage(backImage, forState: .Normal)
        self.backButton.setImage(backImage, forState: .Highlighted)
        self.backButton.tintColor = UIColor.whiteColor()
        self.backButton.backgroundColor = MaterialColor.teal.darken2
    }
    
    private func prepareField() {
        // Do any additional setup after loading the view.
        validationCodeField.clearButtonMode = .WhileEditing
        validationCodeField.placeholder = "認證碼"
        validationCodeField.font = RobotoFont.regularWithSize(20)
        validationCodeField.textColor = MaterialColor.black
        
        // Set textField Padding
        let validationFieldLeftView: UIView = UIView(frame: CGRectMake(0, 0, 10, 10))
        validationCodeField.leftViewMode = .Always
        validationCodeField.leftView = validationFieldLeftView
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func checkValidationButtonClicked(sender: UIButton!) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contactTableView = storyboard.instantiateViewControllerWithIdentifier("MainTabViewController") as! UITabBarController
        self.presentViewController(contactTableView, animated: true, completion: nil)
    }


}
