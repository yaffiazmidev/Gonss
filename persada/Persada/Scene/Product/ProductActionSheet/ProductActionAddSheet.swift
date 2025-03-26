//
//  ProductActionAddSheet.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

protocol ProductActionAddSheetDelegate {
    func didCreateNewProduct()
    func didAddResellerProduct()
}

class ProductActionAddSheet: NSObject {
    private weak var controller : UIViewController?
    private var delegate : ProductActionAddSheetDelegate?
    
    private var rightOptions: [String: ((UIAlertAction) -> Void)] = [
        .get(.createNewProduct): {_ in},
        .get(.addResellerProduct): {_ in},
    ]
    
    override init() {
        super.init()
    }
    
    convenience init(controller: UIViewController, delegate: ProductActionAddSheetDelegate) {
        self.init()
        self.controller = controller
        self.delegate = delegate
        handleRightOption()
    }
    
    func showSheet(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        handleRightOption()
        actionSheet.addAction(addActionSheetMenu(title: .get(.createNewProduct)))
        actionSheet.addAction(addActionSheetMenu(title: .get(.addResellerProduct)))
        actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        actionSheet.overrideUserInterfaceStyle = .light
        
        controller?.present(actionSheet, animated: true, completion: {
            actionSheet.view.superview?.subviews.first?.isUserInteractionEnabled = true
            actionSheet.view.superview?.subviews.first?.onTap(action: {
                actionSheet.dismiss(animated: true)
            })
        })
    }
    
    func addActionSheetMenu(title : String) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: self.rightOptions[title])
    }
    
    
    func handleRightOption(){
        rightOptions = [
            .get(.createNewProduct): {_ in
                self.delegate?.didCreateNewProduct()
            },
            .get(.addResellerProduct): {_ in
                self.delegate?.didAddResellerProduct()
            }
        ]
    }
}
