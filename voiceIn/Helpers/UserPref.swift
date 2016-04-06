import Foundation

class UserPref {
    class func setUserPref(key: String, value: AnyObject?) {
        let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaultData.setValue(value, forKeyPath: key)
    }
    
    class func getUserPrefByKey(key: String) -> String! {
        let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let value: String?? = userDefaultData.stringForKey(key)
        return value!
    }
}