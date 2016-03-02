import Foundation

let API_SANDBOX_END_POINT = "https://voicein-web-service.us-west-2.elasticbeanstalk.com/api/v1/sandboxs"
let API_END_POINT = "https://voicein-web-service.us-west-2.elasticbeanstalk.com/api/v1"
let API_KEY = "f4c34db9-c4f8-4356-9442-51ece7adca67"

class Network {
    init(){
        
    }
    
    static func generateHeader(isTokenNeeded isTokenNeeded: Bool) -> [String: String]? {
        let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var headers: [String: String]?
        
        if isTokenNeeded {
            headers = [
                "apiKey": API_KEY,
                "token": userDefaultData.stringForKey("token")!
            ]
        } else {
            headers = [
                "apiKey": API_KEY
            ]
        }
        
        return headers
    }    
}