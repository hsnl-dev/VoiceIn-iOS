import Foundation
import UIKit
import Alamofire
import SwiftOverlays

class CallService {
    var view: UIView?
    var _self: UIViewController?
    let headers = Network.generateHeader(isTokenNeeded: true)
    
    init(view: UIView, _self: UIViewController) {
        self.view = view
        self._self = _self
    }
    
    func call(userUuid: String!, caller: String!, callee: String!, contactId: String!) {
        let callConfirmAlert = UIAlertController(title: "即將為您撥號", message: "確定撥號嗎?", preferredStyle: UIAlertControllerStyle.Alert)
        
        callConfirmAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: {action in
            
            let callApiRoute = API_URI + versionV2 + "/accounts/" + userUuid + "/calls"
            print(contactId)
            let parameters = [
                "contactId": contactId
            ]
            
            if let superview = self.view!.superview {
                SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "為您撥號中，系統即將來電...")
            }
            
            Alamofire.request(.POST, callApiRoute, encoding: .JSON, headers: self.headers, parameters: parameters).response {
                request, response, data, error in
                
                if let superview = self.view!.superview {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
                
                if error != nil {
                    AlertBox.createAlertView(self._self! ,title: "抱歉!", body: "無法撥打成功，請稍候再試。", buttonValue: "確認")
                    self.view!.userInteractionEnabled = true
                } else {
                    debugPrint(response)
                    if (response?.statusCode)! == 403 {
                        AlertBox.createAlertView(self._self! ,title: "抱歉!", body: "對方為忙碌狀態\n請查看對方可通話時段。", buttonValue: "確認")
                        self.view!.userInteractionEnabled = true
                        return
                    } else if (response?.statusCode)! == 402 {
                        AlertBox.createAlertView(self._self! ,title: "抱歉!", body: "您的點數或對方點數已經用盡，需要儲值。", buttonValue: "確認")
                        self.view!.userInteractionEnabled = true
                        return
                    }
                }
            }
        }))
        
        callConfirmAlert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        _self!.presentViewController(callConfirmAlert, animated: true, completion: nil)
    }
}