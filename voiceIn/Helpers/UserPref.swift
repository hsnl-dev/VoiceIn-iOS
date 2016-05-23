import Foundation

class UserPref {
    init() {
        
    }
    
    class func setUserPref(key: String, value: AnyObject?) {
        let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaultData.setValue(value, forKeyPath: key)
    }
    
    func setUserPref(key: String, value: AnyObject?) -> UserPref {
        let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaultData.setValue(value, forKeyPath: key)
        return self
    }
    
    class func getUserPrefByKey(key: String) -> String! {
        let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let value: String?? = userDefaultData.stringForKey(key)
        return value!
    }
}