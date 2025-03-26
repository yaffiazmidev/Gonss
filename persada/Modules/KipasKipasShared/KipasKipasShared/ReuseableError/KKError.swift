//
//  KKError.swift
//  KipasKipas
//
//  Created by PT.Koanba on 13/07/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

public class KKError {
    
    /** Show custom error message view, it will disappear when user tap on the view or do `onRetry` action when tap on retry button.
     
     - Parameters:
        - at controller: Usually`self` or the controller where this errorView want to be shown.
        - hasTabBar: This to indicate the position of the View should be in top the tabBar or not. default is false.
        - message: The error message to shown.
        - onRetry: the action triggered when `retry button` pressed.
     */
    public static func showError(at controller: UIViewController, hasTabBar: Bool = false, message: String, onRetry: @escaping () -> ()) {
        let errorView = KKErrorView(frame: .zero)
        
        errorView.setErrorMessage(message: message)
        errorView.onRetry = {
            onRetry()
            removeFromSuperview(for: errorView, delay: 0)
        }
        
        errorView.onViewTap = {
            removeFromSuperview(for: errorView, delay: 0)
        }
        
        let view = controller.view
        var bottomPadding: Double = 0.0

        if hasTabBar {
            bottomPadding = 49
        }
        
        
        view?.addSubview(errorView)
        
        errorView.anchor(left: view?.leftAnchor, bottom: view?.safeAreaLayoutGuide.bottomAnchor, right: view?.rightAnchor, paddingBottom: bottomPadding)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            errorView.alpha = 1.0
        }, completion: { _ in })
    }
    
    private static func removeFromSuperview(for view: UIView, delay: Double = 1.5) {
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut, animations: {
            view.alpha = 0.0
        }, completion: {_ in
            view.removeFromSuperview()
        })
    }
}
