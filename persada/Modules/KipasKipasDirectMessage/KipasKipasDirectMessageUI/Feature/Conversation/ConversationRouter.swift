import UIKit
import AVKit
import SendbirdChatSDK
import KipasKipasDirectMessage
import KipasKipasShared

protocol IConversationRouter {
    func presentRevokeActionSheet(onAction: @escaping (() -> Void))
    func presentDeleteActionSheet(messageCount: Int, onDeleteAction: @escaping (() -> Void))
    func presentDeleteAllActionSheet(userName: String, onDeleteAction: @escaping (() -> Void))
    func presentSettingActionSheet(channelMetaData: [String: String]?,
                                   patner: Member?,
                                   onBlockUnBlockUser: @escaping ((Bool) -> Void),
                                   onDeleteMyHistoryChat: @escaping (() -> Void))
    func presentPopUpStopPaidMessage(stopPaidMessageHandler: @escaping (() -> Void))
    func presentLearnMorePaidDM()
    func presentPupUpUnBlockPatner(patnerNickname: String, completion: @escaping (() -> Void))
    func presentMedia(with message: ConversationMessageItem, image: UIImage?)
    func presentVideo(with url: URL?)
    func presentImage(with url: URL?)
    func navigateToPurchaseCoin()
    func openSafariWithURL(_ url: URL)
}

public class ConversationRouter: IConversationRouter {
    
    weak var controller: ConversationViewController?
    
    let baseUrl: String
    let authToken: String
    
    public init(controller: ConversationViewController?, baseUrl: String, authToken: String) {
        self.controller = controller
        self.baseUrl = baseUrl
        self.authToken = authToken
    }
    
    func presentRevokeActionSheet(onAction: @escaping (() -> Void)) {
        let buttonTitle = "Batalkan pesan ini?"
        let deleteChatAction = UIAlertAction(title: buttonTitle, style: .default) { [weak self] _ in
            guard let self = self else { return }
            onAction()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller?.presentActionSheet(actions: [deleteChatAction, cancelAction])
    }
    
    func presentDeleteActionSheet(messageCount: Int, onDeleteAction: @escaping (() -> Void)) {
        let buttonTitle = "Hapus \(messageCount) pesan untuk saya"
        let deleteChatAction = UIAlertAction(title: buttonTitle, style: .default) { [weak self] _ in
            guard let self = self else { return }
            onDeleteAction()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller?.presentActionSheet(actions: [deleteChatAction, cancelAction])
    }
    
    func presentDeleteAllActionSheet(userName: String, onDeleteAction: @escaping (() -> Void)) {
        let deleteChatAction = UIAlertAction(title: .get(.deleteChat), style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let alertDescription = "Chat hanya akan dihapus dari akun kamu, \(userName) masih bisa melihat chat di akunnya, apakah kamu masih ingin menghapus seluruh chat ?"
            
            self.controller?.presentKKPopUpView(
                title: .get(.deleteChat),
                message: alertDescription,
                actionButtonTitle: .get(.deleteChat), onActionTap: {
                    onDeleteAction()
                }
            )
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller?.presentActionSheet(actions: [deleteChatAction, cancelAction])
    }
    
    func presentSettingActionSheet(channelMetaData: [String: String]?, patner: Member?, onBlockUnBlockUser: @escaping ((Bool) -> Void), onDeleteMyHistoryChat: @escaping (() -> Void)) {
        let blockedFrom = channelMetaData?["blocked_from"] ?? ""
        
        let blockAction = UIAlertAction(title: blockedFrom.isEmpty ? .get(.blockUser) : "Buka Blokir Pengguna", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            if let blockedFrom = channelMetaData?["blocked_from"], !blockedFrom.isEmpty {
                self.controller?.presentKKPopUpView(
                    title: "Buka Blokir Pengguna",
                    message: "Buka Blokir Pengguna \(patner?.nickname ?? "") ?",
                    actionButtonTitle: "Buka Blokir Pengguna", onActionTap: { onBlockUnBlockUser(false) }
                )
                return
            }
            
            self.controller?.presentKKPopUpView(
                title: .get(.blockUser),
                message: "\(patner?.nickname ?? "") \(String.get(.blockUserAlertMessage)) \(patner?.nickname ?? "") ?",
                actionButtonTitle: .get(.blockUser), onActionTap: { onBlockUnBlockUser(true) }
            )
        }
        let deleteChatAction = UIAlertAction(title: .get(.deleteChat), style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let alertDescription = "Chat hanya akan dihapus dari akun kamu, \(patner?.nickname ?? "") masih bisa melihat chat di akunnya, apakah kamu masih ingin menghapus seluruh chat ?"
            
            self.controller?.presentKKPopUpView(
                title: .get(.deleteChat),
                message: alertDescription,
                actionButtonTitle: .get(.deleteChat), onActionTap: { onDeleteMyHistoryChat() }
            )
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller?.presentActionSheet(actions: [blockAction, deleteChatAction, cancelAction])
    }
    
    func presentPopUpStopPaidMessage(stopPaidMessageHandler: @escaping (() -> Void)) {
        controller?.presentKKPopUpView(
            title: "Yakin Mengakhiri Sesi?",
            message: "Ketika sesi berakhir, kamu akan kembali kedalam mode pesan biasa dan sisa koin deposit akan dikembalikan ke akun kamu",
            cancelButtonTitle: "Lanjutkan Sesi",
            actionButtonTitle: "Ya, Akhiri Sesi", onActionTap: { stopPaidMessageHandler() })
    }
    
    func presentLearnMorePaidDM() {
        let vc = KKWebViewController(url: "https://kipaskipas.com/kebijakan-privasi-kipaskipas/")
        controller?.present(vc, animated: true)
    }
    
    func presentPupUpUnBlockPatner(patnerNickname: String, completion: @escaping (() -> Void)) {
        controller?.presentKKPopUpView(
            title: .get(.openBlockUser),
            message: "Anda yakin membuka blokir \(patnerNickname) ?",
            actionButtonTitle: .get(.openBlockUser), onActionTap: { completion() })
    }
    
    func presentVideo(with url: URL?) {
        presentMediaPlayer(url: url)
    }
    
    func presentImage(with url: URL?) {
        presentImagePreview(url: url, image: nil)
    }
    
    func presentMedia(with message: ConversationMessageItem, image: UIImage?) {
        guard message.type == "image" else {
            message.media?.url == nil ? playVideoFromData(message.media?.tempData): presentMediaPlayer(url: message.media?.url)
            return
        }
        
        presentImagePreview(url: message.media?.url, image: image)
    }
    
    private func presentMediaPlayer(url: URL?) {
        guard let videoURL = url else {
            controller?.presentAlert(title: "Error", message: "Video url not valid..")
            return
        }
        
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        controller?.present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    private func presentImagePreview(url: URL?, image: UIImage?) {
        let vc = ImagePreviewViewController(url: url, image: image)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        controller?.present(vc, animated: true)
    }
    
    func navigateToPurchaseCoin() {
        let vc = CoinPurchaseRouter.create(baseUrl: baseUrl, authToken: authToken)
        vc.overrideUserInterfaceStyle = .light
        controller?.push(vc)
    }
    
    func playVideoFromData(_ data: Data?) {
        guard let data = data else {
            print("Video data not found..")
            return
        }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("video.mp4")
        
        do {
            try data.write(to: tempURL)
            
            let asset = AVAsset(url: tempURL)
            let player = AVPlayer()
            player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
            let playerVC = AVPlayerViewController()
            playerVC.player = player
            
            player.play()
            
            controller?.present(playerVC, animated: true) {
                player.play()
            }
        } catch {
            print(error)
        }
    }
    
    func openSafariWithURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Handle the case where the URL is invalid or Safari cannot be opened
            controller?.presentAlert(title: "", message: "URL is invalid or Safari cannot be opened..")
        }
    }
}
