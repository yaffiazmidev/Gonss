//
//  UIViewController+Extension.swift
//  Persada
//
//  Created by Muhammad Noor on 04/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func dateToString(date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    func stringToDate(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.date(from: date)
    }
    
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }

        return self
    }
    
    func addChildViewControllerWithView(_ childViewController: UIViewController, toView view: UIView? = nil) {
        let view: UIView = view ?? self.view
        
        childViewController.removeFromParent()
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    func removeChildViewController(_ childViewController: UIViewController) {
        childViewController.removeFromParent()
        childViewController.willMove(toParent: nil)
        childViewController.removeFromParent()
        childViewController.didMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.name = "hideKeyboard"
        view.addGestureRecognizer(tap)
    }
    
    func disableHideKeyboardTappedAround() {
        var gestures = view.gestureRecognizers
        gestures?.forEach({ item in
            if item.name == "hideKeyboard" {
                view.removeGestureRecognizer(item)
            }
        })
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-120, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showLongToast(message : String, showDuration: Double = 0.1, fadeOutDuration: Double = 4.0) {
        let font = UIFont.Roboto(.medium, size: 14)
        let width = UIScreen.main.bounds.width * 0.9
        let height = message.height(withConstrainedWidth: width, font: font) + 10
        let x = (UIScreen.main.bounds.width - width) / 2
        let y = UIScreen.main.bounds.height - height - 100
        
        let toastLabel = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = font
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: fadeOutDuration, delay: showDuration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func changeStatusBar(with color: UIColor) {
        let defaultStatusBar =  UIView()
        defaultStatusBar.frame = UIApplication.shared.windows.map { $0 }.first?.windowScene?.statusBarManager!.statusBarFrame as! CGRect
        defaultStatusBar.backgroundColor = color
        defaultStatusBar.tintColor = .white
        
        setNeedsStatusBarAppearanceUpdate()
        
        UIApplication.shared.windows.map { $0 }.first?.addSubview(defaultStatusBar)
    }
    
    var named: String {
        String(describing: type(of: self)).components(separatedBy: ".").first ?? ""
    }
    
    static var named: String {
        String(describing: type(of: self)).components(separatedBy: ".").first ?? ""
    }
    
    
    @objc private func onClickBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func onClickBackPresent()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
//    @objc private func onClickEllipse(_ sender: UIBarButtonItem) {
//        
//    }

    @objc private func dismissButton() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func bindNavigationBar(_ title: String? = "", _ isBack: Bool = true, icon: String = .get(.arrowleft), customSize: CGSize? = nil, contentHorizontalAlignment: UIControl.ContentHorizontalAlignment? = nil, contentVerticalAlignment: UIControl.ContentVerticalAlignment? = nil ) {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: icon), for: UIControl.State())
        if isBack {
            btnLeftMenu.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        } else {
            btnLeftMenu.addTarget(self, action: #selector(dismissButton), for: .touchUpInside)
        }
        
        if let size = customSize {
            btnLeftMenu.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        } else {
            btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33/2, height: 27/2)
        }
        
        if let verticalAlignment = contentVerticalAlignment {
            btnLeftMenu.contentVerticalAlignment = verticalAlignment
        }
        
        if let horizontalAlignment = contentHorizontalAlignment {
            btnLeftMenu.contentHorizontalAlignment = horizontalAlignment
        }
        
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationItem.title = title ?? ""
    }
    
    func bindNavigationRightBar(_ title: String? = "", _ isBackPopOrDismiss: Bool = true, icon: String = .get(.iconClose)) {
        let btnRightBar: UIButton = UIButton()
        btnRightBar.setImage(UIImage(named: icon), for: UIControl.State())
        if isBackPopOrDismiss {
            btnRightBar.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        } else {
            btnRightBar.addTarget(self, action: #selector(onClickBackPresent), for: .touchUpInside)
        }
        
        btnRightBar.frame = CGRect(x: 0, y: 0, width: 33/2, height: 27/2)
        let barButton = UIBarButtonItem(customView: btnRightBar)
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationItem.title = title ?? ""
    }
    
    func setupNavbar() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.hideKeyboardWhenTappedAround()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)), style: .plain, target: self, action: #selector(onClickBack))
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    func setupNavbarForPresent() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.hideKeyboardWhenTappedAround()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)), style: .plain, target: self, action: #selector(onClickBackPresent))
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    func setupNavbarWithoutLeftItem() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.hideKeyboardWhenTappedAround()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.backgroundColor = .white
    }
}

extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

extension UIView {
fileprivate var hairlineImageView: UIImageView? {
    return hairlineImageView(in: self)
}

fileprivate func hairlineImageView(in view: UIView) -> UIImageView? {
    if let imageView = view as? UIImageView, imageView.bounds.height <= 1.0 {
        return imageView
    }

    for subview in view.subviews {
        if let imageView = self.hairlineImageView(in: subview) { return imageView }
    }
    return nil
  }
}

extension UIViewController {
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController

        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    func smartBack(animated: Bool, completion: (()->Void)? = nil) {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: animated, completion: completion)
        } else {
            self.navigationController?.popViewController(animated: animated)
            completion?()
        }
    }
}
