//
//  DonationActionSheet.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit

struct DonationActionSheetData {
    
    let id: String
    let title: String
    let image: String
    let initiatorId: String
    
    init(id: String, title: String, image: String, initiatorId: String) {
        self.id = id
        self.title = title
        self.image = image
        self.initiatorId = initiatorId
    }
}

class DonationActionSheet : NSObject {
    private var rightOptions: [String: ((UIAlertAction) -> Void)] = [
        .get(.sharedAnotherMedia): {_ in},
//        .get(.sendToDM): {_ in},
    ]
    
    private weak var controller : UIViewController?
    private var data : DonationActionSheetData?
    
    override init() {
        super.init()
    }
    
    convenience init(controller: UIViewController) {
        self.init()
        self.controller = controller
        handleRightOption()
    }
    
    func showSheet(_ data: DonationActionSheetData){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.data = data
        handleRightOption()
        
//        actionSheet.addAction(addActionSheetMenu(title: .get(.sendToDM)))
        actionSheet.addAction(addActionSheetMenu(title: .get(.sharedAnotherMedia)))
        
        
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
    
    func addActionSheetMenu(title : String, handlerName: String? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: self.rightOptions[handlerName ?? title])
    }
    
    
    func handleRightOption(){
        rightOptions = [
            .get(.sharedAnotherMedia): {_ in
                self.shareToAnotherMedia()
            },
//            .get(.sendToDM): {_ in
//                self.sendToDm()
//            },
        ]
    }
    
    func sendToDm() {
        //TODO : Send to DM
    }
    
    func shareToAnotherMedia(){
        guard let data = self.data else { return }
        let text =  "Kirim Donasi \(data.title) - Klik link berikut untuk membuka tautan: \(APIConstants.webURL)/donation/\(data.id)"
        let item = CustomShareItem(id: data.id, message: text, type: .donation, assetUrl: data.image, accountId: data.initiatorId, name: data.title, price: nil)
        let vc = KKShareController(mainView: KKShareView(), item: item)
        controller?.present(vc, animated: true, completion: nil)
    }
    
    func showDialog(title: String, desc: String){
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .light
        
        alert.addAction(UIAlertAction(title: .get(.ok), style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        controller?.present(alert, animated: true, completion: nil)
    }
}
