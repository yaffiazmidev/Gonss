//
//  CustomShareViewModel.swift
//  KipasKipas
//
//  Created by PT.Koanba on 09/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit
import KipasKipasShared

class CustomShareViewModel : NSObject {
    private let customShare : CustomShare!
    private let item: CustomShareItem
    
    private(set) var socmedShare : [CustomShareModel]! {
        didSet {
            self.bindSocmedShareViewModelToController()
        }
    }
    
    private(set) var localShare : [CustomShareModel]! {
        didSet {
            self.bindLocalShareViewModelToController()
        }
    }
    
    var bindSocmedShareViewModelToController : (() -> ()) = {}
    var bindLocalShareViewModelToController : (() -> ()) = {}
    var bindLoading : ((Bool) -> ()) = {_ in }
    var bindError: ((String) -> ()) = {_ in }
    
    init(controller: UIViewController, item: CustomShareItem) {
        self.customShare = CustomShare(controller: controller)
        self.item = item
        super.init()
        
        getAvailableSocmed()
        makeLocalShareData()
        
        customShare.bindLoading = { [weak self] isLoading in
            self?.bindLoading(isLoading)
        }
        customShare.bindError = { [weak self] error in
            self?.bindError(error)
        }
    }
    
    func getAvailableSocmed() {
        socmedShare = customShare.customShareModelList
    }
    
    func makeLocalShareData() {
        localShare = [
            CustomShareModel(
                icon: UIImage(named: .get(.iconShareDownload)),
                title: "Save in gallery", type: .saveToGallery
            ),
            CustomShareModel(
                icon: UIImage(named: .get(.iconShareLink)),
                title: "Copy Link", type: .copyLink
            )
        ]
        
        if  getIdUser() == item.accountId && item.type != .donation {
            localShare.append(
                CustomShareModel(
                    icon: UIImage(named: .get(.iconShareDelete)),
                    title: "Delete",
                    type: .delete
                )
            )
        }else{
            localShare.append(
                CustomShareModel(
                    icon: UIImage(named: .get(.iconShareReport)),
                    title: "Report",
                    type: .report
                )
            )
        }
        
        
        localShare.append(
            CustomShareModel(
                icon: UIImage(named: .get(.iconShareMore)),
                title: "More", type: .more
            )
        )
    }
    
    func handleCellClick(data: CustomShareModel, completion: @escaping (_ success: Bool, _ message: String) -> ()) {
        switch data.type {
        case .facebook:
            //            if isNews {
            //                customShare.shareTextToFacebookText(message: message)
            //            } else {
            customShare.shareToFacebook(item: item)
            //            }
        case .instagramDirectMessage:
            customShare.shareToInstagramDirectMessage(message: item.message)
        case .instagramFeed:
            if KKMediaItemExtension.isPhoto(item.assetUrl) {
                customShare.shareToInstagramFeedImage(item: item)
            } else {
                customShare.shareToInstagramFeedVideo(url: item.assetUrl)
            }
        case .instagramStory:
            if KKMediaItemExtension.isPhoto(item.assetUrl) {
                customShare.shareToInstagramStoryImage(item: item)
            } else {
                customShare.shareToInstagramStoryVideo(url: item.assetUrl)
            }
        case .whatsappStatus:
            customShare.shareToWhatsappStatusAndChat(message: item.message)
        case .whatsapp:
            customShare.shareToWhatsappStatusAndChat(message: item.message)
        case .saveToGallery:
            if item.type == .content || item.type == .donation {
                
                guard let url = URL(string: item.assetUrl) else {
                    DispatchQueue.main.async { Toast.share.show(message: "Something went wrong, please try again..") }
                    return
                }
                
                DispatchQueue.main.async { KKLoading.shared.show(message: "Please wait..") }
                
                AlamofireMediaDownloadManager.shared.downloadMediaToCameraRoll(
                    mediaURL: url,
                    progressHandler: { progress in
                        DispatchQueue.main.async { KKLoading.shared.show(message: "Downloading.. \(Int(progress * 100))%") }
                    }
                ) { result in
                    DispatchQueue.main.async { KKLoading.shared.hide() }
                    switch result {
                    case .success(_):
                        DispatchQueue.main.async { Toast.share.show(message: "Media saved to photo library.") }
                    case .failure(let error):
                        let error = error as NSError
                        if error.code == -1 {
                            completion(false, "permission")
                            return
                        }
                        DispatchQueue.main.async { Toast.share.show(message: "Something went wrong, please try again..") }
                    }
                }

                return
            }
            
            customShare.downloadCustomShareProduct(item: item) {
                DispatchQueue.main.async {
                    completion(true, "Success save in gallery")
                }
            }
        case .copyLink:
            if let validIndex = item.message.index(of: "https") {
                let substring = item.message[validIndex...]
                let validURL = String(substring)
                customShare.copyLink(url: validURL)
            }
            completion(true, "Success copy to clipboard")
        case .report:
            customShare.report(item: item)
        case .delete:
            guard let id = item.id else { return }
            customShare.delete(id: id)
        case .more:
            if item.type == .content {
                customShare.more(message: item.message)
                return
            }
            
            customShare.defaultShare(item: item)
        }
    }
}
