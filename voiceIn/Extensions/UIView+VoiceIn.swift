import UIKit

extension UIView {
    func image() -> UIImage {
        var image: UIImage!
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.mainScreen().scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            CGContextTranslateCTM(context, -frame.origin.x - 4, 0)
            
            if let scrollView = self as? UIScrollView {
                CGContextTranslateCTM(context, -scrollView.contentOffset.x, -scrollView.contentOffset.y)
            }
            
            layer.renderInContext(context)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else {
            image = UIImage()
        }
        
        return image
    }
}