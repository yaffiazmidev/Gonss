import UIKit
import Photos
import KipasKipasShared
import KipasKipasDirectMessage
import RxSwift

class KKShareController: UIViewController, AlertDisplayer {
    
    private let mainView: KKShareView!
    private var viewModel : CustomShareViewModel!
    private let item: CustomShareItem!
    private let showAddToStory: Bool
    private let showRepost: Bool
    var onClickReport: (() -> Void)?
    var onAddToStory: (() -> Void)?
    var onRepost: (() -> Void)?
    var onDelete: (() -> Void)?
    
    var didDisappear: EmptyClosure?
    
    init(mainView: KKShareView, item: CustomShareItem, showAddToStory: Bool = false, showRepost: Bool = false) {
        self.mainView = mainView
        self.mainView.item = item
        self.item = item
        self.showAddToStory = showAddToStory
        self.showRepost = showRepost
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareModel()
        
        mainView.handleClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        mainView.backgroundView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.dismiss(animated: true)
        }
        
        
        if AUTH.isLogin() {
            requestFollower()
        } else {
            mainView.followings = []
        }
        
        if showRepost {
            mainView.addRepostOption()
        }
    }
     
    override func loadView() {
        super.loadView()
        view = mainView
        mainView.collectionView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            NotificationCenter.default.post(name: .shouldResumePlayer, object: nil)
            didDisappear?()
        }
    }
    
    func prepareModel(){
        viewModel = CustomShareViewModel(controller: self, item: self.item)
    }
    
    func requestFollower() {
        let endpoint = Endpoint<RemoteFollowingItem?>(
            path: "profile/\(getIdUser())/following",
            method: .get,
            headerParamaters: [
                "Authorization" : "Bearer \(getToken() ?? "")",
                "Content-Type":"application/json"
            ],
            queryParameters: ["page" : "0", "size": "10"]
        )
        
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.mainView.followings = response?.data?.content ?? []
                if self.showAddToStory {
                    self.mainView.followings.insert(RemoteFollowingContent(id: getIdUser(), username: getUsername(), name: getName(), photo: getPhotoURL()), at: 0)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension KKShareController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if indexPath.section == 0 {
            if indexPath.item == 0 && showAddToStory {
                dismiss(animated: true) {
                    self.onAddToStory?()
                }
                return
            }
            sendContentToDM(
                userId: mainView.followings[indexPath.item].id ?? "",
                username: mainView.followings[indexPath.item].username ?? "",
                message: item.message
            )
            return
        }
        
        if indexPath.section == 1 {
            var n = 0
            
            if showRepost {
                n = 1
                if indexPath.item == 0 {
                    dismiss(animated: true) {
                        self.onRepost?()
                    }
                    return
                }
            }
            
            if indexPath.item == 0 + n {
                let copyLink = CustomShareModel(
                    icon: UIImage(named: .get(.iconShareLink)),
                    title: "Copy Link", type: .copyLink
                )
                
                viewModel.handleCellClick(data: copyLink) {[weak self] success, message in
                    guard let self = self else { return }
                    
                    if !success && message == "permission" {
                        showAlertForAskPhotoPermisson()
                        return
                    }
                    
                    self.displayAlert(with: String.get(.success), message: message, actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
                }
            }
            
            if indexPath.item == 1 + n {
                DispatchQueue.main.async {
                    if UIApplication.shared.canOpenURL(URL(string: "instagram://sharesheet")!) {
                        let message = self.item.message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        
                        guard let url  = URL(string: "instagram://sharesheet?text=\(message ?? "")") else { return }
                        UIApplication.shared.open(url, options: [:]) { success in
                            if success {
                                print("Instagram accessed successfully")
                            } else {
                                print("Error accessing Instagram")
                            }
                        }
                    }
                }
            }
            
            if indexPath.item == 2 + n {
                if UIApplication.shared.canOpenURL(URL(string: "whatsapp://app")!) {
                    let message = self.item.message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
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
        
        if indexPath.section == 2 {
            if indexPath.item == 0 {
                if getIdUser() == item.accountId {
                    let delete = CustomShareModel(
                        icon: UIImage(named: "ic_trashCan_solid_black"),
                        title: "Delete", type: .delete
                    )
                    if let onDelete = onDelete {
                        onDelete()
                    } else {
                        viewModel.handleCellClick(data: delete) {[weak self] success, message in
                            guard let self = self else { return }
                            
                            if !success {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { Toast.share.show(message: "Maaf terjadi kesalahan, silahkan coba lagi..")}
                                return
                            }
                            
                            self.displayAlert(with: String.get(.success), message: message, actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
                        }
                    }
                } else {
                    showFeedReport?(.init(
                        targetReportedId: item.id ?? "",
                        accountId: item.accountId,
                        username: item.username,
                        kind: item.type == .live ? .LIVE_STREAMING :.FEED,
                        delegate: self
                    ))
                }
                
            }
            
            if indexPath.item == 1 {
                
                let saveVideo = CustomShareModel(
                    icon: UIImage(named: .get(.iconShareDownload)),
                    title: "Save video", type: .saveToGallery
                )
                
                guard !item.assetUrl.isEmpty else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { Toast.share.show(message: "Maaf video tidak tersedia..")}
                    return
                }
                
                viewModel.handleCellClick(data: saveVideo) {[weak self] success, message in
                    guard let self = self else { return }
                    
                    if !success && message == "permission" {
                        showAlertForAskPhotoPermisson()
                        return
                    }
                    
                    self.displayAlert(with: String.get(.success), message: message, actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
                }
            }
        }
        
        
        
        /*
        var item: CustomShareModel?
        if indexPath.section == 1 {
            if indexPath.row == 0 {
            } else if indexPath.row == 1 {
                item = CustomShareModel(icon: UIImage(named: .get(.iconShareLink)), title: "Copy Link", type: .copyLink)
            } else if indexPath.row == 2 {
                item = CustomShareModel(icon: UIImage(named: .get(.iconIG)), title: "Instagram Direct Message", type: .instagramDirectMessage)
            } else if indexPath.row == 3 {
                item = CustomShareModel(icon: UIImage(named: .get(.iconIG)), title: "Instagram Feed", type: .instagramFeed)
            } else if indexPath.row == 4 {
                item = CustomShareModel(icon: UIImage(named: .get(.iconIG)), title: "Instagram Story", type: .instagramStory)
            } else if indexPath.row == 7 {
                item = CustomShareModel(icon: UIImage(named: .get(.iconFB)), title: "Facebook", type: .facebook)
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                item = CustomShareModel(icon: UIImage(named: .get(.iconShareReport)), title: "Report", type: .report)
            } else if indexPath.row == 2 {
                item = CustomShareModel(icon: UIImage(named: .get(.iconShareDownload)),title: "Save in gallery", type: .saveToGallery)
            }
        } else {
            print("section 0")
            if indexPath.row >= 0 || indexPath.row < 4 {
                print("section \(indexPath.row)")
            }
        }
        guard let validItem = item else { return }
         */
        
//        var item: CustomShareModel?
//        if indexPath.section == 1 {
//            if indexPath.row == 1 {
//                item = CustomShareModel(
//                    icon: UIImage(named: .get(.iconShareLink)),
//                    title: "Copy Link", type: .copyLink
//                )
//            }
//        } else if indexPath.section == 2 {
//            if indexPath.row == 1 {
//                print("section \(indexPath.row)")
//            }
//        } else {
//            print("section 0")
//            if indexPath.row >= 0 || indexPath.row < 4 {
//                print("section \(indexPath.row)")
//            }
//        }
//        guard let copyLink = item else { return }
//
//        viewModel.handleCellClick(data: copyLink) {[weak self] success, message in
//            guard let self = self else { return }
//
//            if !success && message == "permission" {
//                showAlertForAskPhotoPermisson()
//                return
//            }
//
//            self.displayAlert(with: String.get(.success), message: message, actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
//        }
    }
    
    func presentInProgressAlert() {
        let vc = CustomPopUpViewController(
            title: "Fitur sedang dalam proses pengembangan.",
            description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
            iconImage: UIImage(named: "img_in_progress"),
            iconHeight: 99
        )
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
        /*
        onClickReport?()
        collectionView.deselectItem(at: indexPath, animated: false)
         */
    }
}

// MARK: - Report Handler
extension KKShareController: ReportFeedDelegate {
    func reported() {
        if let id = self.item.id {
            NotificationCenter.default.post(name: .handleReportFeed, object: nil, userInfo: ["id": id])
        }
    }
}

private extension KKShareController {
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

extension KKShareController {
    func sendContentToDM(userId: String, username: String, message: String) {
        let manager = TXIMMessageManager(userId: userId)
        if let _ = manager.sendTextMessage(with: message) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { Toast.share.show(message: "Sent to \(username)", backgroundColor: UIColor(hexString: "#4A4A4A"))}
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { Toast.share.show(message: "Error: Failed to send this content..")}
        }
    }
}
