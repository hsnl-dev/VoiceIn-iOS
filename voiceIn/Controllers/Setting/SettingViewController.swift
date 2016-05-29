import UIKit

class SettingViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setTutorialOnSegue" {
            UserPref()
                    .setUserPref("isFirstLogin", value: "true")
                    .setUserPref("isFirstFetch", value: true)
        }
    }
    
    @IBAction func logout(sender: UIButton) {
        UserPref()
            .setUserPref("isFirstLogin", value: "true")
            .setUserPref("isFirstFetch", value: true)
            .setUserPref("userUuid", value: nil)
            .setUserPref("token", value: nil)
        let rootController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = rootController
    }
    
    @IBAction func closeTheEditProfileModal(segue: UIStoryboardSegue) {
        
    }
    
}
