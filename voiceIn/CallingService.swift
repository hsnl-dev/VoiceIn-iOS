import Foundation
import UIKit
import Alamofire

class CallService {
    var view: UIView?
    var _self: UIViewController?
    let headers = Network.generateHeader(isTokenNeeded: true)
    
    init(view: UIView, _self: UIViewController) {
        self.view = view
        self._self = _self
    }
    
    func call(userUuid: String!, caller: String!, callee: String!) {
        let callConfirmAlert = UIAlertController(title: "即將為您撥號", message: "確定撥號嗎?", preferredStyle: UIAlertControllerStyle.Alert)
        
        callConfirmAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: {action in
            
            let callApiRoute = API_END_POINT + "/accounts/" + userUuid + "/calls"
            let delay = 1.2 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            let parameters = [
                "caller": caller,
                "callee": callee
            ]
            
            self.createAlertView("為您撥號中...", body: "幾秒後系統即將來電，請放心接聽", buttonValue: "確認")
            
            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                self._self!.dismissViewControllerAnimated(true, completion: nil)
            }
            
            Alamofire.request(.POST, callApiRoute, encoding: .JSON, headers: self.headers, parameters: parameters).response {
                request, response, data, error in
                if error != nil {
                    debugPrint(error)
                    
                    self.createAlertView("抱歉!", body: "無法撥打成功，請稍候再試。", buttonValue: "確認")
                    self.view!.userInteractionEnabled = true
                }
            }
        }))
        
        callConfirmAlert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        _self!.presentViewController(callConfirmAlert, animated: true, completion: nil)
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        _self!.presentViewController(alert, animated: true, completion: nil)
    }
}