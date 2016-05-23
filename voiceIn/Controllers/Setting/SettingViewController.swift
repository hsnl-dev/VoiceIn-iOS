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
    
    @IBAction func closeTheEditProfileModal(segue: UIStoryboardSegue) {
        
    }
    
}
