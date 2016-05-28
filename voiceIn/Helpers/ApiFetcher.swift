import Foundation
import SystemConfiguration

let API_SANDBOX_END_POINT = "https://voicein-web-service.us-west-2.elasticbeanstalk.com/api/v1/sandboxs"
let isSandBox = false
let API_END_POINT = isSandBox == true ? "https://voicein.herokuapp.com/api/v2" : "https://voicein-api.kits.tw/api/v2"
let API_URI = isSandBox == true ? "https://voicein.herokuapp.com/api/" : "https://voicein-api.kits.tw/api/"
let versionV1 = "v1"
let versionV2 = "v2"
let latestVersion = "v2"
let API_KEY = "f4c34db9-c4f8-4356-9442-51ece7adca67"
let QRCODE_ROUTE = isSandBox == true ? "https://voice-in.herokuapp.com/qrcode?id=" : "https://voicein.kits.tw/qrcode?id="

class Network {
    init(){
        
    }
    
    class func generateHeader(isTokenNeeded isTokenNeeded: Bool) -> [String: String]? {
        var headers: [String: String]?
        
        if isTokenNeeded {
            headers = [
                "apiKey": API_KEY,
                "token": UserPref.getUserPrefByKey("token") == nil ? UserPref.getUserPrefByKey("tempToken") : UserPref.getUserPrefByKey("token")
            ]
        } else {
            headers = [
                "apiKey": API_KEY
            ]
        }
        
        debugPrint(headers)
        
        return headers
    }    
}