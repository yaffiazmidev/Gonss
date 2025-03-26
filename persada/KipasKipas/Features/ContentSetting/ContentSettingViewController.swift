//
//  ContentSettingViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 15/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import FeedCleeps
import KipasKipasShared
import Photos

class ContentSettingViewController: BaseHalfViewController {

    lazy var mainView: ContentSettingContainerView = {
        let view = ContentSettingContainerView()
        view.delegate = self
        return view
    }()
    
    private let viewModel: ContentSettingViewModel
    private var lastScrollPoint: CGFloat = 0.0
    private let feed: FeedItem
    
    init(feed: FeedItem, viewModel: ContentSettingViewModel) {
        self.feed = feed
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        mainView.feed = feed
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        handleOnTap()
        defaultRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topPinterView.isHidden = true
        viewHeight = 400
        updateContainerHeight(400)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addMainView(with: mainView)
    }
    
    private func configureUI() {
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .clear
        containerView.backgroundColor = UIColor(hexString: "#F5F5F5")
    }
    
    private func handleOnTap() {
        mainView.shareToIGImageView.onTap { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(URL(string: "instagram://sharesheet")!) {
                    let message = self.createShareMessage().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    guard let url  = URL(string: "instagram://sharesheet?text=\(message ?? "")") else { return }
                    UIApplication.shared.open(url, options: [:]) { success in
                        if success {
                            print("Instagram accessed successfully")
                        } else {
                            print("Error accessing Instagram")
                        }
                    }
                } else {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { Toast.share.show(message: "Anda tidak punya app ig") }
                }
            }
        }
        
        mainView.shareToWhatsappImageView.onTap { [weak self] in
            guard let self = self else { return }
            
            if UIApplication.shared.canOpenURL(URL(string: "whatsapp://app")!) {
                let message = self.createShareMessage().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
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
    
    private func defaultRequest() {
        viewModel.requestFollower()
    }
    
    func presentInProgressAlert() {
        let vc = CustomPopUpViewController(
            title: "Fitur sedang dalam proses pengembangan.",
            description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
            iconImage: UIImage(named: "img_in_progress"),
            iconHeight: 99
        )
        present(vc, animated: false)
    }
    
    private func createShareMessage() -> String {
        let username = feed.account?.name ?? "KIPASKIPAS"
        let contentLink = "\(APIConstants.webURL)/feed/\(feed.id ?? "")"
        let contentDesc = feed.post?.description ?? ""
        let message = "\(username) \n\n\(contentDesc) \n\n\nKlik link berikut untuk membuka tautan: \(contentLink)"
        return message
    }
}

// MARK: - Report Handler
extension ContentSettingViewController: ReportFeedDelegate {
    func reported() {
        if let id = self.feed.id {
            NotificationCenter.default.post(name: .handleReportFeed, object: nil, userInfo: ["id": id])
        }
    }
}

extension ContentSettingViewController: ContentSettingContainerViewDelegate {
    
    func didClickSendContentTo(userId: String) {
        DispatchQueue.main.async { KKLoading.shared.show(message: "Sending..") }
        viewModel.sendContentToDM(userId: userId, message: createShareMessage())
    }
    
    func didRefresh() {
        defaultRequest()
    }
    
    func didClickRepost() {
        presentInProgressAlert()
    }
    
    func didClickMoreFollowing() {
        presentInProgressAlert()
    }
    
    func didClickCopyLink() {
        handleCopyLink()
    }
    
    func didClickSettingItem(with menu: ContentSettingMenu) {
        switch menu {
        case .report:
            guard let id = feed.id else { return }
            showFeedReport?(.init(
                targetReportedId: id,
                accountId: feed.account?.id ?? "",
                username: feed.account?.username ?? "",
                kind: .FEED,
                delegate: self
            ))
        case .saveVideo:
//            let text =  "\(feed.account?.name ?? "KIPASKIPAS") \n\n\(feed.post?.description ?? "") \n\n\nKlik link berikut untuk membuka tautan: \(APIConstants.webURL)/feed/\(feed.id ?? "")"
//            guard let url = feed.post?.medias?.first?.url, let accountId = feed.account?.id else { return }
//            let item = CustomShareItem(message: text, type: .content, assetUrl: url, accountId: accountId)
            
            if feed.feedType == .donation {
                if !feed.videoUrl.isEmpty {
                    handleSaveMediaToGallery(assetsURL: feed.videoUrl)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { Toast.share.show(message: "Maaf video tidak tersedia..")}
                }
            } else {
                if let url = feed.post?.medias?.first?.url, !url.isEmpty {
                    handleSaveMediaToGallery(assetsURL: url)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { Toast.share.show(message: "Maaf video tidak tersedia..")}
                }
            }
            
        case .savePhoto:
            let assetsURL = feed.post?.medias?.first?.thumbnail?.large ?? ""
            handleSaveMediaToGallery(assetsURL: assetsURL)
        case .deletePost:
            let confirmationPopUp = KKAlertViewController.composeUIWith(
                title: "Hapus Postingan",
                desc: "Postingan yang sudah dihapus tidak dapat dilihat dan dikembalikan lagi.",
                okButtonText: "Hapus"
            )
            confirmationPopUp.modalTransitionStyle = .crossDissolve
            confirmationPopUp.modalPresentationStyle = .overFullScreen
            confirmationPopUp.onTapOK = { [weak self] in
                guard let self = self else { return}
                DispatchQueue.main.async { KKLoading.shared.show(message: "Please wait..") }
                viewModel.deletePost(with: self.feed.id)
            }
            
            self.present(confirmationPopUp, animated: true)
        default:
            presentInProgressAlert()
        }
    }
}

private extension ContentSettingViewController {
    
    private func handleCopyLink() {
        let isDonation = feed.typePost == "donation"
        let type: CustomShareItemType = isDonation ? .donation : .content
        let path = isDonation ? "donation" : "feed"
        let id = feed.id
        
        let text =  "\(feed.account?.name ?? "KIPASKIPAS") \n\n\(feed.post?.description ?? "") \n\n\nKlik link berikut untuk membuka tautan: \(APIConstants.webURL)/\(path)/\((isDonation ? feed.post?.id : feed.id) ?? "")"
        let url = feed.post?.medias?.first?.url ?? ""
        let accountId = feed.account?.id ?? ""
        let item = CustomShareItem(id: id, message: text, type: type, assetUrl: url, accountId: accountId, name: feed.post?.title, username: feed.account?.username)
        
        if let validIndex = item.message.index(of: "https") {
            let substring = item.message[validIndex...]
            let validURL = String(substring)
            UIPasteboard.general.string = validURL
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { Toast.share.show(message: "Success copy to clipboard", backgroundColor: UIColor(hexString: "#4A4A4A")) }
    }
    
    private func handleSaveMediaToGallery(assetsURL: String) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if status == .authorized {
                    // Access granted, you can perform actions that require access here
                    self.downloadMediaToCameraRoll(with: URL(string: assetsURL))
                } else {
                    // Access denied or restricted
                    self.showAlertForAskPhotoPermisson()
                }
            }
        }
    }
    
    private func downloadMediaToCameraRoll(with url: URL?) {
        
        guard let url = url else {
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
                    self.showAlertForAskPhotoPermisson()
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { Toast.share.show(message: "Maaf video tidak tersedia..")}
            }
        }
    }
    
    private func showAlertForAskPhotoPermisson() {
        let actionSheet = UIAlertController(title: "", message: .get(.photosask), preferredStyle: .alert)
        let selectPhotosAction = UIAlertAction(title: .get(.photosselected), style: .default) { _ in
            // Show limited library picker
            if #available(iOS 14, *) {
                
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            } else {
                // Fallback on earlier versions
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
        actionSheet.addAction(selectPhotosAction)
        
        let allowFullAccessAction = UIAlertAction(title: .get(.photosaccessall), style: .default) { _ in
            // Open app privacy settings
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: .get(.cancel), style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        DispatchQueue.main.async { self.present(actionSheet, animated: true) }
    }
}


extension ContentSettingViewController: ContentSettingViewModelDelegate {
    func displaySendContent(userId: String) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        guard let user = mainView.followings.filter({ $0.id == userId }).first else { return }
        mainView.alreadySendToUsers.append(user)
        mainView.tableView.reloadData()
    }
    
    func displayFollowers(with response: [RemoteFollowingContent]) {
        mainView.refreshControl.endRefreshing()
        mainView.emptyFollowingContainerStackView.isHidden = !response.isEmpty
        mainView.tableView.isHidden = response.isEmpty
        mainView.followings = response
        mainView.tableView.reloadData()
    }
    
    func displayError(with message: String) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        mainView.refreshControl.endRefreshing()
    }
    
    func displayErrorDeletePost(with message: String) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .handleDeleteFeed, object: nil, userInfo: nil)
        }
    }
    
    func displaySuccessDeletePost(id: String?) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .handleDeleteFeed, object: nil, userInfo: ["id": id ?? ""])
        }
    }
}
