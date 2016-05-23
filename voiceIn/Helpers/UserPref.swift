import Foundation
import Alamofire

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
    
    class func updateTheDeviceKey() {
        let userUuid = UserPref.getUserPrefByKey("userUuid")
        let deviceKey = UserPref.getUserPrefByKey("deviceKey")
        let updateInformationApiRoute = API_END_POINT + "/accounts/" + userUuid + "/device"
        let headers = Network.generateHeader(isTokenNeeded: true)
        
        let parameters = [
            "deviceOS": "ios",
            "deviceKey": deviceKey
        ]
        
        Alamofire
            .request(.PUT, updateInformationApiRoute, parameters: parameters, encoding: .JSON, headers: headers)
            .response { request, response, data, error in
                debugPrint(response)
            }

    }
}