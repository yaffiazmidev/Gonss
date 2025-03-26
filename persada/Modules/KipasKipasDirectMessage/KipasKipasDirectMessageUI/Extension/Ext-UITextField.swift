//
//  Ext-UITextField.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 27/07/23.
//

import UIKit

extension UITextField {
    private struct AssociatedKeys {
        static var timer = "timer"
    }
    
    var delayedActionTimer: Timer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.timer) as? Timer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.timer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addDelayedAction(with delay: TimeInterval, action: @escaping () -> Void) {
        // Invalidate the previous timer, if any
        delayedActionTimer?.invalidate()
        
        // Set a new timer with the specified delay
        delayedActionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { timer in
            action()
        }
    }
}
