//
//  NotificationBanner.swift
//  CWNotificationBanner
//
//  Created by Charlie Williams on 12/04/2016.
//  Copyright © 2016 Charlie Robert Williams, Ltd. All rights reserved.
//

import UIKit

public func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.text == rhs.text && lhs.date == rhs.date
}

public enum MessageType: String {
    case NoConnection = "No network connection."
    case ServerError = "Error connecting to the server."
    case Unspecified = "We couldn't complete that request."
    case NotLoggedIn = "Error: Please log out and log in again to continue."
}

public enum PushPayloadKey: String {
    case aps = "aps"
    case alert = "alert"
    case action = "a"
    case duration = "d"
}

public typealias Action = (() -> ())

public struct Message : Equatable {
    public let text: String
    public var actionKey: String?
    public let duration: NSTimeInterval
    private let date: NSDate
    private let isError: Bool
    private static let defaultDisplayTime: NSTimeInterval = 5
    private static var actions = [String:Action]()
    
    public init(text: String, displayDuration: NSTimeInterval = defaultDisplayTime, isError error: Bool = false) {
        self.text = text
        self.date = NSDate()
        self.duration = displayDuration
        self.isError = error
    }
    
    public init?(pushPayload: [NSObject : AnyObject]) {
        
        guard let text = pushPayload[PushPayloadKey.aps.rawValue]?[PushPayloadKey.alert.rawValue] as? String else { return nil }
        self.text = text
        self.actionKey = pushPayload[PushPayloadKey.action.rawValue] as? String
        self.duration = pushPayload[PushPayloadKey.duration.rawValue] as? NSTimeInterval ?? Message.defaultDisplayTime
        self.date = NSDate()
        self.isError = false
    }
    
    public static func registerAction(action: Action, forKey key: String) {
        actions[key] = action
    }
    
    public static func registerActionsAndKeys(actionsAndKeys:[String:Action]) {
        for (key, action) in actionsAndKeys {
            actions[key] = action
        }
    }
    
    public static func unregisterActionForKey(key: String) {
        actions.removeValueForKey(key)
    }
    
    public func isEqual(other: AnyObject?) -> Bool {
        guard let o = other as? Message else { return false }
        return o.text == text && o.date == date
    }
}

public class NotificationBanner: UIToolbar {
    
    public static func showMessage(message: Message) {
        
        guard NSThread.mainThread() == NSThread.currentThread() else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                showMessage(message)
            }
            return
        }
        
        if let timer = currentMessageTimer,
            let interruptedMessage = pendingMessages.last where timer.valid {
            let index = pendingMessages.count >= 2 ? pendingMessages.count - 2 : 0
            pendingMessages.insert(interruptedMessage, atIndex: index)
        }
        
        // Don't interrupt an error to show a non-error
        if let currentMessage = pendingMessages.last where currentMessage.isError {
            let index = pendingMessages.count >= 2 ? pendingMessages.count - 2 : 0
            pendingMessages.insert(message, atIndex: index)
            return
        }
        
        if !pendingMessages.contains(message) {
            pendingMessages.append(message)
        }
        
        sharedToolbar.styleForError(message.isError)
        sharedToolbar.frame = messageHiddenFrame
        sharedToolbar.messageLabel.text = message.text
        
        UIView.animateWithDuration(animateDuration) {
            sharedToolbar.frame = messageShownFrame
        }
        
        currentMessageTimer?.invalidate()
        currentMessageTimer = NSTimer.after(message.duration) {
            
            pendingMessages = pendingMessages.filter { $0 != message }
            
            hideCurrentMessage(true, alreadyRemoved: true) {
                if let next = pendingMessages.last {
                    showMessage(next)
                }
            }
        }
    }
    
    public static func showErrorMessage(messageType: MessageType, code: Int? = nil) {
        
        var text = messageType.rawValue
        if let code = code where code != 0 {
            text = String(text.characters.dropLast()) + ": \(code)"
        }
        let message = Message(text: text, isError: true)
        showMessage(message)
    }
    
    public static func cancelMessage(toCancel: Message, animated: Bool = true) {
        guard NSThread.mainThread() == NSThread.currentThread() else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                cancelMessage(toCancel, animated: animated)
            }
            return
        }
        
        if let current = currentMessage where toCancel == current {
            hideCurrentMessage(animated)
        } else {
            pendingMessages = pendingMessages.filter { $0 != toCancel }
        }
    }
    
    public static func cancelAllMessages(animated: Bool) {
        guard NSThread.mainThread() == NSThread.currentThread() else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                cancelAllMessages(animated)
            }
            return
        }
        
        hideCurrentMessage(animated)
        pendingMessages = []
    }
    
    @IBOutlet private weak var messageLabel: UILabel!
    private var underStatusBarView: UIView!
    public static var sharedToolbar: NotificationBanner = {
        let bundle = NSBundle(forClass: NotificationBanner.classForCoder())
        let t = bundle.loadNibNamed(String(NotificationBanner), owner: nil, options: nil).first as! NotificationBanner
        t.hideHairlineBorder()
        t.addStatusBarBackingView()
        t.barTintColor = UIColor(white: 0.2, alpha: 0.4)
        UIApplication.sharedApplication().keyWindow!.addSubview(t)
        return t
    }()
    
    private static var currentMessageTimer: NSTimer?
    private static var currentMessage: Message?
    private static var pendingMessages = [Message]()
    
    private static let animateDuration: NSTimeInterval = 0.3
    private class var messageShownFrame: CGRect {
        let y = UIApplication.sharedApplication().statusBarHidden ? 0 : UIApplication.sharedApplication().statusBarFrame.height
        return CGRect(x: 0, y: y, width: sharedToolbar.frame.width, height: sharedToolbar.frame.height)
    }
    private class var messageHiddenFrame: CGRect {
        return CGRect(x: 0, y: -sharedToolbar.frame.height, width: sharedToolbar.frame.width, height: sharedToolbar.frame.height)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private static func hideCurrentMessage(animated: Bool, alreadyRemoved: Bool = false, completion: (()->())? = nil) {
        
        if !alreadyRemoved && pendingMessages.count > 0 {
            pendingMessages.removeLast()
        }
        
        if animated {
            UIView.animateWithDuration(animateDuration, animations: {
                sharedToolbar.frame = messageHiddenFrame
                }, completion: { finished in
                    completion?()
            })
        } else {
            sharedToolbar.frame = messageHiddenFrame
            completion?()
        }
        
        currentMessageTimer?.invalidate()
        currentMessageTimer = nil
        currentMessage = nil
    }
    
    @IBAction func popoverTapped(sender: UIBarButtonItem) {
        if let key = NotificationBanner.currentMessage?.actionKey,
            let action = Message.actions[key] {
            action()
        }
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        NotificationBanner.hideCurrentMessage(true) {
            if let next = NotificationBanner.pendingMessages.last {
                NotificationBanner.showMessage(next)
            }
        }
    }
    
    private let errorBackgroundColor = UIColor(white: 0.2, alpha: 1.0)
    private let regularBackgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1)
    override public var barTintColor: UIColor? {
        didSet {
            underStatusBarView.backgroundColor = barTintColor?.colorWithAlphaComponent(0.85)
        }
    }
    
    private func styleForError(isError: Bool) {
        barTintColor = isError ? errorBackgroundColor : regularBackgroundColor
        messageLabel.textColor = UIColor.blackColor()
    }
    
    private func hideHairlineBorder() {
        for view in subviews {
            if let imageView = view as? UIImageView {
                imageView.hidden = true
            }
        }
    }
    
    private func addStatusBarBackingView() {
        let underStatusBar = UIView(frame: CGRectZero)
        underStatusBar.backgroundColor = UIColor(white: 0.2, alpha: 0.85)
        underStatusBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(underStatusBar)
        let views = ["underStatusBar":underStatusBar]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[underStatusBar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(-20)-[underStatusBar(20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        underStatusBarView = underStatusBar
    }
}