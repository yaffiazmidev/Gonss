//
//  Ext-UIViewController.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 12/07/23.
//

import UIKit

extension UIViewController {
    
    func bindNavBar(_ title: String = "", isPresent: Bool = false, completion: (() -> Void)? = nil) {
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.leftBarButtonItem = makeDefaultNavBarBackButton(title, isPresent: isPresent, completion: completion)
    }
    
    func makeDefaultNavBarBackButton(_ title: String = "", isPresent: Bool = false, completion: (() -> Void)? = nil) -> UIBarButtonItem {
        
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.shadowImage = UIImage()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .black
        titleLabel.font = .Roboto(.medium, size: 14)
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.translatesAutoresizingMaskIntoConstraints = false
        let backIcon: UIImage? = UIImage(named: "iconArrowLeft")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        btnLeftMenu.setImage(backIcon, for: .normal)
//        btnLeftMenu.setBackgroundImage(backIcon, for: .normal)
        btnLeftMenu.heightAnchor.constraint(equalToConstant: 24).isActive = true
        btnLeftMenu.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
       // if isPresent {
            btnLeftMenu.addTarget(self, action: #selector(dismissButtonTappedWithCompletion), for: .touchUpInside)
       // } else {
            btnLeftMenu.addTarget(self.navigationController, action: #selector(UINavigationController.popViewController(animated:)), for: .touchUpInside)
        //}
        
        objc_setAssociatedObject(self, &AssociatedKeys.dismissCompletion, completion, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        let backItemContainerStackView = UIStackView()
        backItemContainerStackView.axis = .horizontal
        backItemContainerStackView.spacing = 4
        backItemContainerStackView.alignment = .center
        backItemContainerStackView.distribution = .fill
        backItemContainerStackView.addArrangedSubview(btnLeftMenu)
        backItemContainerStackView.addArrangedSubview(titleLabel)
        
        return UIBarButtonItem(customView: title.isEmpty ? btnLeftMenu : backItemContainerStackView)
    }
    
    @objc func dismiss(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
    
    @objc private func dismissButtonTappedWithCompletion() {
            // Perform custom actions before dismissing (if needed)
            
            dismiss(animated: true) {
                // Completion block: code to execute after the view controller is dismissed
                if let completion = objc_getAssociatedObject(self, &AssociatedKeys.dismissCompletion) as? () -> Void {
                    completion()
                }
            }
        }
    
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
//    func setNavigationBarShadow() {
//        navigationController?.navigationBar.backgroundColor = .white
//        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
//        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 4)
//        navigationController?.navigationBar.layer.shadowOpacity = 0.05
//        navigationController?.navigationBar.layer.shadowRadius = 3
//        navigationController?.navigationBar.layer.masksToBounds = false
//        navigationController?.navigationBar.shadowImage = UIImage()
//    }
//
//    func hideNavigationBarShadow() {
//        navigationController?.navigationBar.backgroundColor = .white
//        navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
//        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 4)
//        navigationController?.navigationBar.layer.shadowOpacity = 0.05
//        navigationController?.navigationBar.layer.shadowRadius = 3
//        navigationController?.navigationBar.layer.masksToBounds = false
//        navigationController?.navigationBar.shadowImage = UIImage()
//    }
}

extension UIViewController {
    public static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: Bundle(for: T.self))
        }

        return instantiateFromNib()
    }
    
    public func presentAlert(title: String, message: String?, closeHandler: (() -> Void)? = nil) {
        presentAlert(title: title, message: message, buttonTitle: nil, closeHandler: closeHandler)
    }
    
    public func presentAlert(title: String, message: String?, buttonTitle: String?, closeHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var btnTitle = buttonTitle ?? "Close"
        alert.addAction(UIAlertAction(title: btnTitle, style: .cancel, handler: { _ in closeHandler?() }))
        present(alert, animated: true)
    }
    
    public func presentTextFieldAlert(title: String, message: String?, defaultTextFieldMessage: String, didConfirm: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = defaultTextFieldMessage
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak alert] _ in
            guard let textFieldText = alert?.textFields?.first?.text else { return }
            
            didConfirm(textFieldText)
        })
        
        present(alert, animated: true)
    }
    
    public func presentAlert(error: Error) {
        presentAlert(title: "Error", message: error.localizedDescription)
    }
}

extension UIViewController {
    public func presentKKPopUpView(
			title: String,
			message: String,
			isHiddenCancelButton: Bool = false,
			imageName: String? = nil,
			cancelButtonTitle: String = "Batalkan",
			actionButtonTitle: String = "OK",
			onActionTap: (() -> Void)? = nil,
			onCancelTap: (() -> Void)? = nil,
			onCloseTap: (() -> Void)? = nil
		) {
        let vc = KKPopUpViewViewController(
					title: title,
					message: message,
					isHiddenCancelButton: isHiddenCancelButton,
					imageName: imageName,
					cancelButtonTitle: cancelButtonTitle,
					actionButtonTitle: actionButtonTitle
				)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.handleTapActionButton = onActionTap
        vc.handleTapCancelButton = onCancelTap
        vc.handleTapCloseButton = onCloseTap
        present(vc, animated: true)
    }
	
	func presentKKPopUpViewCustomImage(title: String, message: String, isHiddenCancelButton: Bool = false, cancelButtonTitle: String = "Batalkan", actionButtonTitle: String = "OK", imageName: String? = nil, onActionTap: (() -> Void)? = nil) {
			let vc = KKPopUpViewControllerV2(title: title, message: message, isHiddenCancelButton: isHiddenCancelButton, cancelButtonTitle: cancelButtonTitle, actionButtonTitle: actionButtonTitle)
			vc.modalPresentationStyle = .overFullScreen
			vc.modalTransitionStyle = .crossDissolve
			vc.handleTapActionButton = onActionTap
			vc.changeImage(name: imageName)
			present(vc, animated: true)
	}
	
	func presentKKPopUpViewWithImageAndText(
        title: String,
        message: String,
        isHiddenCancelButton: Bool = false,
        isHiddenCloseButton: Bool = false,
        cancelButtonTitle: String = "Batalkan",
        actionButtonTitle: String = "OK",
        imageName: String? = nil,
        secondTitle: String?,
        secondSubtitle: String?,
        isHidden: Bool?,
        onActionTap: (() -> Void)? = nil,
        onCancelTap: (() -> Void)? = nil
    ) {
        let vc = KKPopUpViewControllerV2(title: title, message: message, isHiddenCancelButton: isHiddenCancelButton, cancelButtonTitle: cancelButtonTitle, actionButtonTitle: actionButtonTitle, isHiddenCloseButton: isHiddenCloseButton)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.handleTapActionButton = onActionTap
        vc.handleTapCancelButton = onCancelTap
        vc.changeImage(name: imageName)
        vc.configureSecondText(isHidden: isHidden, title: secondTitle, subtitle: secondSubtitle)
        present(vc, animated: true)
	}
}

extension UIViewController {
    func presentActionSheet(title: String? = nil, message: String? = nil, actions: [UIAlertAction], completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        for action in actions {
            alertController.addAction(action)
        }

        present(alertController, animated: true, completion: completion)
    }
}

private struct AssociatedKeys {
    static var dismissCompletion = "dismissCompletion"
}

extension UIViewController {
    var isDeviceWithHomeButton: Bool {
        get {
            guard UIDevice.current.userInterfaceIdiom == .phone else {
                return false
            }
            
            let nativeBoundsHeight = UIScreen.main.nativeBounds.height
            
            guard nativeBoundsHeight == 1334 || nativeBoundsHeight == 1920 || nativeBoundsHeight == 2208 else {
                return false
            }
            
            return true
        }
    }
}
