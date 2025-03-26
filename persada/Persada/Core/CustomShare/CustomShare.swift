//
//  CustomShare.swift
//  KipasKipas
//
//  Created by PT.Koanba on 18/10/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Kingfisher
import RxSwift
import KipasKipasShared

class CustomShare : NSObject, UIDocumentInteractionControllerDelegate {
    private weak var controller : UIViewController?
    
    private var documentController : UIDocumentInteractionController!
    private let downloadManager = DownloadManager()
    private var documentInteractionController : UIDocumentInteractionController!
    
    // For report Feed
    private var reportController: ReportFeedController?
    private var reportFeedId: String?
    
    // For delete Feed
    private let usecase: FeedUseCase
    let disposeBag = DisposeBag()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    
    private enum SocialMediaURIschemes : String {
        case facebook = "fb://"
        case instagram = "instagram://app"
        case instagramStoryShare = "instagram-stories://share"
        case instagramDirectMessage = "instagram://sharesheet"
        case whatsapp = "whatsapp://app"
    }
    
    var customShareModelList : [CustomShareModel] {
        get {
            self.decideIcon()
        }
    }
    
    private(set) var isLoading : Bool! {
        didSet {
            self.bindLoading(isLoading)
        }
    }
    
    var bindLoading : ((Bool) -> ()) = {_ in }
    var bindError : ((String) -> ()) = {_ in }
    
    private lazy var qrLayout : KKQRLayout = {
        let view = KKQRLayout.instanceFromNib()
        return view
    }()
    
    private var showFacebook = false
    private var showInstagram = false
    private var showWhatsapp = false
    
    private let instagramBackgroundGradientColor = ("#636e72","#b2bec3")
    
    private let excludedActivityTypes = [
        UIActivity.ActivityType.print,
        UIActivity.ActivityType.airDrop,
        UIActivity.ActivityType.openInIBooks,
        UIActivity.ActivityType.copyToPasteboard,
        UIActivity.ActivityType.addToReadingList,
        UIActivity.ActivityType.assignToContact,
        UIActivity.ActivityType.copyToPasteboard,
        UIActivity.ActivityType.mail,
        UIActivity.ActivityType.markupAsPDF,
        UIActivity.ActivityType.postToWeibo,
        UIActivity.ActivityType.postToVimeo,
        UIActivity.ActivityType.postToFlickr,
        UIActivity.ActivityType.postToTwitter,
        UIActivity.ActivityType.postToTencentWeibo,
        UIActivity.ActivityType.saveToCameraRoll,
        UIActivity.ActivityType.message,
        UIActivity.ActivityType(rawValue: "com.apple.CloudDocsUI.AddToiCloudDrive"),
        UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
        UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
        UIActivity.ActivityType(rawValue: "com.amazon.Lassen.SendToKindleExtension"),
        UIActivity.ActivityType(rawValue: "com.google.chrome.ios.ShareExtension"),
        UIActivity.ActivityType(rawValue: "com.google.Drive.ShareExtension"),
        UIActivity.ActivityType(rawValue: "com.google.Gmail.ShareExtension"),
        UIActivity.ActivityType(rawValue: "com.google.inbox.ShareExtension"),
        UIActivity.ActivityType(rawValue: "com.google.hangouts.ShareExtension"),
        UIActivity.ActivityType(rawValue: "com.iwilab.KakaoTalk.Share"),
        UIActivity.ActivityType(rawValue: "com.hammerandchisel.discord.Share"),
        UIActivity.ActivityType(rawValue: "com.facebook.Messenger.ShareExtension"),
        UIActivity.ActivityType(rawValue: "com.nhncorp.NaverSearch.ShareExtension"),
        UIActivity.ActivityType(rawValue: "com.linkedin.LinkedIn.ShareExtension"),
        UIActivity.ActivityType(rawValue: "net.whatsapp.WhatsApp.ShareExtension"),
        UIActivity.ActivityType(rawValue: "com.tinyspeck.chatlyio.share"), // Slack!
        UIActivity.ActivityType(rawValue: "ph.telegra.Telegraph.Share"),
        UIActivity.ActivityType(rawValue: "com.toyopagroup.picaboo.share"), // Snapchat!
        UIActivity.ActivityType(rawValue: "com.fogcreek.trello.trelloshare"),
        UIActivity.ActivityType(rawValue: "com.hammerandchisel.discord.Share"),
        UIActivity.ActivityType(rawValue: "com.riffsy.RiffsyKeyboard.RiffsyShareExtension"), //GIF Keyboard by Tenor
        UIActivity.ActivityType(rawValue: "com.ifttt.ifttt.share"),
        UIActivity.ActivityType(rawValue: "com.getdropbox.Dropbox.ActionExtension"),
        UIActivity.ActivityType(rawValue: "wefwef.YammerShare"),
        UIActivity.ActivityType(rawValue: "pinterest.ShareExtension"),
        UIActivity.ActivityType(rawValue: "pinterest.ActionExtension"),
        UIActivity.ActivityType(rawValue: "us.zoom.videomeetings.Extension"),
    ]
    
    override init() {
        self.usecase = Injection.init().provideFeedUseCase()
        super.init()
    }
    
    convenience init(controller: UIViewController) {
        self.init()
        self.controller = controller
        
        qrLayout.bindError = { error in
            self.bindError(error)
        }
    }
    
    func downloadCustomShareProduct(item: CustomShareItem ,completion: @escaping () -> ()){
        guard let item = item.toKKQRItem() else { return }
        isLoading = true
        qrLayout.generateQR(item: item){_ in
            completion()
            self.isLoading = false
        }
    }
    
    func downloadToCameraRoll(url: String, completion: @escaping () -> ()){
        isLoading = true
        let completion = BlockOperation {
            
            let loaderDelegate = SimpleResourceLoaderDelegate(withURL: URL(string: url) ?? URL(fileURLWithPath: ""))
            guard let filepath = loaderDelegate.getVideoIfExist() else { fatalError() }
            guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
            PHPhotoLibrary.shared().performChanges({
                if filepath.absoluteString.contains(".jpg") {
                    let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: filepath)
                    changeRequest?.creationDate = Date()
                } else {
                    let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filepath)
                    changeRequest?.creationDate = Date()
                }
            }) { completed, error in
                if completed {
                    completion()
                    self.isLoading = false
                }
                self.isLoading = false
            }
        }
        
        guard let url = URL(string: url) else { fatalError() }
        if self.downloadManager.isFileExists(url: url) {
        } else {
            let operation = self.downloadManager.queueDownload(url)
            completion.addDependency(operation)
        }
        
        OperationQueue.main.addOperation(completion)
    }
    
    func copyLink(url : String){
        UIPasteboard.general.string = url
    }
    
    private func decideIcon() -> [CustomShareModel] {
        var customShareModelList : [CustomShareModel] = []
        if UIApplication.shared.canOpenURL(URL(string: SocialMediaURIschemes.facebook.rawValue)!) {
            showFacebook = true
            customShareModelList += [CustomShareModel(icon: UIImage(named: .get(.iconFB)), title: "Facebook", type: .facebook)]
        }
        
        if UIApplication.shared.canOpenURL(URL(string: SocialMediaURIschemes.instagram.rawValue)!) {
            showInstagram = true
            customShareModelList += [CustomShareModel(icon: UIImage(named: .get(.iconIG)), title: "Instagram Feed", type: .instagramFeed)]
            customShareModelList += [CustomShareModel(icon: UIImage(named: .get(.iconIG)), title: "Instagram Story", type: .instagramStory)]
        }
        
        if UIApplication.shared.canOpenURL(URL(string: SocialMediaURIschemes.whatsapp.rawValue)!) {
            showWhatsapp = true
            customShareModelList += [CustomShareModel(icon: UIImage(named: .get(.iconWhatsapp)), title: "Whatsapp", type: .whatsapp)]
            customShareModelList += [CustomShareModel(icon: UIImage(named: .get(.iconWhatsapp)), title: "Whatsapp Status", type: .whatsappStatus)]
        }
        return customShareModelList
    }
    
    func defaultShare(item: CustomShareItem){
        isLoading = true
        if item.type == .content {
            downloadToCameraRoll(url: item.assetUrl, completion: {
                let loaderDelegate = SimpleResourceLoaderDelegate(withURL: URL(string: item.assetUrl) ?? URL(fileURLWithPath: ""))
                guard let loaderDelegateURL = loaderDelegate.getVideoIfExist() else { fatalError() }
                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(activityItems: [loaderDelegateURL], applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = self.controller?.view
                    
                    self.controller?.present(activityVC, animated: true, completion: nil)
                }
                self.isLoading = false
            })
            return
        }
        
        guard let item = item.toKKQRItem() else {
            isLoading = false
            return
        }
        
        qrLayout.generateQR(item: item){ image in
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let tempFile = NSURL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/\(item.id).jpg")!
                do {
                    try imageData.write(to: tempFile, options: .atomic)
                    self.documentController = UIDocumentInteractionController(url: tempFile)
                    self.documentController.presentOpenInMenu(from: CGRect.zero, in: (self.controller?.view)!, animated: true)
                } catch {
                    print(error)
                }
                self.isLoading = false
            }
        }
    }
    
    func more(message: String) {
        let activityViewController = UIActivityViewController(activityItems : [message], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.controller?.view
        
        self.controller?.present(activityViewController, animated: true, completion: nil)
    }
    
    func report(item: CustomShareItem) {
        if let id = item.id {
            reportFeedId = id
            showFeedReport?(.init(
                targetReportedId: id,
                accountId: item.accountId, 
                username: item.username,
                kind: .FEED, 
                delegate: self
            ))
        }
    }
    
    func delete(id: String) {
        
        let confirmationPopUp = KKAlertViewController.composeUIWith(
            title: "Hapus Postingan",
            desc: "Postingan yang sudah dihapus tidak dapat dilihat dan dikembalikan lagi.",
            okButtonText: "Hapus"
        )
        confirmationPopUp.modalTransitionStyle = .crossDissolve
        confirmationPopUp.modalPresentationStyle = .overFullScreen
        confirmationPopUp.onTapOK = { [weak self] in
            guard let self = self else { return}
            
            usecase.deleteFeedById(id: id)
                .subscribeOn(self.concurrentBackground)
                .observeOn(MainScheduler.instance)
                .subscribe{ result in
                    //                guard let self = self else { return }
                    //                self._loadingState.accept(false)
                } onError: { err in
                    
                    self.controller?.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: .handleDeleteFeed, object: nil, userInfo: nil)
                    })
                } onCompleted: {
                    self.controller?.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: .handleDeleteFeed, object: nil, userInfo: ["id": id])
                    })
                }.disposed(by: disposeBag)
            
        }
        
        controller?.present(confirmationPopUp, animated: true)
    }
}

// MARK: Facebook Share
extension CustomShare {
    func shareToFacebook(item: CustomShareItem){
        self.isLoading = true
        
        if item.type == .content {
            downloadToCameraRoll(url: item.assetUrl, completion: {
                let loaderDelegate = SimpleResourceLoaderDelegate(withURL: URL(string: item.assetUrl) ?? URL(fileURLWithPath: ""))
                guard let loaderDelegateURL = loaderDelegate.getVideoIfExist() else { fatalError() }
                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(activityItems: [loaderDelegateURL], applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = self.controller?.view
                    activityVC.excludedActivityTypes = self.excludedActivityTypes
                    
                    self.controller?.present(activityVC, animated: true, completion: nil)
                    self.isLoading = false
                }
            })
            return
        }
        
        generateUrlFromLatestImage(item: item) { responseURL in
            DispatchQueue.main.async {
                guard let url = responseURL else { return }
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.controller?.view
                activityVC.excludedActivityTypes = self.excludedActivityTypes
                
                self.controller?.present(activityVC, animated: true, completion: nil)
                self.isLoading = false
            }
        }
    }
    
    func shareTextToFacebookText(message: String){
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.controller?.view
        activityVC.excludedActivityTypes = self.excludedActivityTypes
        
        self.controller?.present(activityVC, animated: true, completion: nil)
        self.isLoading = false
    }
}

// MARK: Whatsapp Share
extension CustomShare {
    
    func shareToWhatsapp(item: CustomShareItem){
        self.isLoading = true
        if item.type == .content {
            downloadToCameraRoll(url: item.assetUrl, completion: {
                let loaderDelegate = SimpleResourceLoaderDelegate(withURL: URL(string: item.assetUrl) ?? URL(fileURLWithPath: ""))
                guard let loaderDelegateURL = loaderDelegate.getVideoIfExist() else { fatalError() }
                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(activityItems: [loaderDelegateURL], applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = self.controller?.view
                    activityVC.excludedActivityTypes = self.excludedActivityTypes + [UIActivity.ActivityType.postToFacebook]
                    
                    self.controller?.present(activityVC, animated: true, completion: nil)
                    
                }
                self.isLoading = false
            })
            return
        }
        
        guard let item = item.toKKQRItem() else {
            isLoading = false
            return
        }
        
        qrLayout.generateQR(item: item){ image in
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let tempFile = NSURL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/\(item.id ).jpg")!
                do {
                    try imageData.write(to: tempFile, options: .atomic)
                    self.documentController = UIDocumentInteractionController(url: tempFile)
                    self.documentController.presentOpenInMenu(from: CGRect.zero, in: (self.controller?.view)!, animated: true)
                } catch {
                    print(error)
                }
                self.isLoading = false
            }
        }
    }
    
    func shareToWhatsappStatusAndChat(message: String){
        if UIApplication.shared.canOpenURL(URL(string: SocialMediaURIschemes.whatsapp.rawValue)!) {
            let message = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            guard let url  = URL(string: "whatsapp://send?text=\(message ?? "")") else { return }
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("WhatsApp accessed successfully")
                } else {
                    print("Error accessing WhatsApp")
                }
            }
        }
        
    }
}
// MARK: Instagram Share
extension CustomShare {
    
    func shareToInstagramStoryImage(item: CustomShareItem){
        isLoading = true
        if item.type == .content {
            guard let url = URL(string: item.assetUrl) else { fatalError() }
            let resource = KF.ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resource, options: .none, progressBlock: .none, downloadTaskUpdated: .none) { [weak self] result in
                switch result {
                case .success(let value):
                    if let storiesUrl = URL(string: SocialMediaURIschemes.instagramStoryShare.rawValue) {
                        if UIApplication.shared.canOpenURL(storiesUrl) {
                            guard let imageData = value.image.pngData() else { return }
                            guard let self = self else { fatalError() }
                            let pasteboardItems: [String: Any] = [
                                "com.instagram.sharedSticker.backgroundImage": imageData,
                                "com.instagram.sharedSticker.backgroundTopColor": self.instagramBackgroundGradientColor.0,
                                "com.instagram.sharedSticker.backgroundBottomColor": self.instagramBackgroundGradientColor.1
                            ]
                            let pasteboardOptions = [
                                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                            ]
                            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                            UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                            self.isLoading = false
                            //                        controller?.dismiss(animated: true, completion: nil)
                        } else {
                            /// handle don't have instagram
                        }
                    }
                case .failure(let error):
                    self?.isLoading = false
                    print("Error: \(error)")
                }
            }
            return
        }
        
        guard let item = item.toKKQRItem() else {
            isLoading = false
            return
        }
        
        if let storiesUrl = URL(string: SocialMediaURIschemes.instagramStoryShare.rawValue) {
            if UIApplication.shared.canOpenURL(storiesUrl) {
                qrLayout.generateQR(item: item){ image in
                    
                    guard let imageData = image.pngData() else { return }
                    let pasteboardItems: [String: Any] = [
                        "com.instagram.sharedSticker.backgroundImage": imageData,
                        "com.instagram.sharedSticker.backgroundTopColor": self.instagramBackgroundGradientColor.0,
                        "com.instagram.sharedSticker.backgroundBottomColor": self.instagramBackgroundGradientColor.1
                    ]
                    let pasteboardOptions = [
                        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                    ]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                    self.isLoading = false
                    
                }
                
            }
        }
        
        isLoading = false
    }
    
    func shareToInstagramStoryVideo(url: String){
        self.isLoading = true
        if let storiesUrl = URL(string: SocialMediaURIschemes.instagramStoryShare.rawValue) {
            if UIApplication.shared.canOpenURL(storiesUrl) {
                guard let url = URL(string: url) else { fatalError() }
                guard let data = try? Data(contentsOf: url) else { fatalError() }
                let pasteboardItems: [String: Any] = [
                    "com.instagram.sharedSticker.backgroundVideo": data,
                    "com.instagram.sharedSticker.backgroundTopColor": instagramBackgroundGradientColor.0,
                    "com.instagram.sharedSticker.backgroundBottomColor": instagramBackgroundGradientColor.1                ]
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                ]
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                self.isLoading = false
                //                controller?.dismiss(animated: true, completion: nil)
            } else {
                /// handle don't have instagram
            }
        }
    }
    
    func shareToInstagramStoryAsSticker(url: String){
        self.isLoading = true
        
        guard let url = URL(string: url) else { fatalError() }
        let resource = KF.ImageResource(downloadURL: url)
        KingfisherManager.shared.retrieveImage(with: resource, options: .none, progressBlock: .none, downloadTaskUpdated: .none) { [weak self] result in
            switch result {
            case .success(let value):
                if let storiesUrl = URL(string: SocialMediaURIschemes.instagramStoryShare.rawValue) {
                    if UIApplication.shared.canOpenURL(storiesUrl) {
                        guard let imageData = value.image.pngData() else { return }
                        guard let self = self else { fatalError() }
                        let pasteboardItems: [String: Any] = [
                            "com.instagram.sharedSticker.stickerImage": imageData,
                            "com.instagram.sharedSticker.backgroundTopColor": self.instagramBackgroundGradientColor.0,
                            "com.instagram.sharedSticker.backgroundBottomColor": self.instagramBackgroundGradientColor.1
                        ]
                        let pasteboardOptions = [
                            UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                        ]
                        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                        UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                        self.isLoading = false
                        
                        //                        controller?.dismiss(animated: true, completion: nil)
                    } else {
                        /// handle don't have instagram
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                self?.isLoading = false
                return
            }
        }
        
    }
    
    func shareToInstagramFeedVideo(url : String){
        self.isLoading = true
        downloadToCameraRoll(url: url, completion: {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
            if let igUrl = URL(string: SocialMediaURIschemes.instagram.rawValue) {
                DispatchQueue.main.async {
                    if UIApplication.shared.canOpenURL(igUrl) {
                        guard let identifier = fetchResult.firstObject?.localIdentifier else { fatalError() }
                        let urlWithIdentifier = "instagram://library?LocalIdentifier=\(identifier)"
                        let url = NSURL(string: urlWithIdentifier)!
                        if UIApplication.shared.canOpenURL(url as URL) {
                            UIApplication.shared.open(URL(string: urlWithIdentifier)!, options: [:], completionHandler: nil)
                        }
                        self.isLoading = false
                    } else {
                        /// handle don't have instagram
                    }
                }
            }
        })
    }
    
    func shareToInstagramFeedImage(item: CustomShareItem){
        self.isLoading = true
        if item.type == .content {
            downloadToCameraRoll(url: item.assetUrl, completion: {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                if let igUrl = URL(string: SocialMediaURIschemes.instagram.rawValue) {
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(igUrl) {
                            guard let identifier = fetchResult.firstObject?.localIdentifier else { fatalError() }
                            let urlWithIdentifier = "instagram://library?LocalIdentifier=\(identifier)"
                            let url = NSURL(string: urlWithIdentifier)!
                            if UIApplication.shared.canOpenURL(url as URL) {
                                UIApplication.shared.open(URL(string: urlWithIdentifier)!, options: [:], completionHandler: nil)
                            }
                        } else {
                            /// handle don't have instagram
                        }
                        self.isLoading = false
                    }
                }
            })
            return
        }
        
        guard let item = item.toKKQRItem() else {
            isLoading = false
            return
        }
        
        qrLayout.generateQR(item: item){ _ in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            if let igUrl = URL(string: SocialMediaURIschemes.instagram.rawValue) {
                DispatchQueue.main.async {
                    if UIApplication.shared.canOpenURL(igUrl) {
                        guard let identifier = fetchResult.firstObject?.localIdentifier else { fatalError() }
                        let urlWithIdentifier = "instagram://library?LocalIdentifier=\(identifier)"
                        let url = NSURL(string: urlWithIdentifier)!
                        if UIApplication.shared.canOpenURL(url as URL) {
                            UIApplication.shared.open(URL(string: urlWithIdentifier)!, options: [:], completionHandler: nil)
                        }
                    } else {
                        /// handle don't have instagram
                    }
                }
            }
            self.isLoading = false
        }
    }
    
    func shareToInstagramDirectMessage(message: String){
        isLoading = true
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(URL(string: SocialMediaURIschemes.instagramDirectMessage.rawValue)!) {
                let message = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                guard let url  = URL(string: "instagram://sharesheet?text=\(message ?? "")") else { return }
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        print("Instagram accessed successfully")
                        self.isLoading = false
                    } else {
                        print("Error accessing Instagram")
                        self.isLoading = true
                    }
                }
            }
        }
    }
}

extension CustomShare {
    func generateUrlFromLatestImage(item: CustomShareItem, completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        guard let item = item.toKKQRItem() else {
            completionHandler(nil)
            return
        }
        
        isLoading = true
        qrLayout.generateQR(item: item){_ in
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2) {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                fetchResult.firstObject?.getURL(completionHandler: { responseURL in
                    completionHandler(responseURL)
                })
                self.isLoading = false
            }
            return
        }
    }
}

private extension PHAsset {
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

// MARK: - Report Handler
extension CustomShare: ReportFeedDelegate {
    func reported() {
        self.reportController?.dismiss(animated: false)
        self.controller?.dismiss(animated: false)
        if let id = self.reportFeedId {
            NotificationCenter.default.post(name: .handleReportFeed, object: nil, userInfo: ["id": id])
        }
    }
}

// MARK: - Converter
fileprivate extension CustomShareItem {
    func toKKQRItem() -> KKQRItem? {
        var type: KKQRType?
        switch self.type {
        case .shop:
            type = .shop
        case .donation:
            type = .donation
        default: return nil
        }
        
        guard let type = type, let id = self.id, let name = self.name else { return nil }
        return KKQRItem(type: type, id: id, data: KKQRDataItem(name: name, price: Int(self.price ?? 0), image: self.assetUrl))
    }
}
