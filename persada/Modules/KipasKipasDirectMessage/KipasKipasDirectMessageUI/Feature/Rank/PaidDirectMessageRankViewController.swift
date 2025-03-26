//
//  PaidDirectMessageRankViewController.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 05/08/23.
//

import UIKit
import KipasKipasDirectMessage
import SendbirdChatSDK

protocol IPaidDirectMessageRankViewController: AnyObject {
    func displayChatRank(users: [RemoteChatRankData])
    func displayError(message: String)
    func displayCreateChannel(channel: GroupChannel?)
}

public class PaidDirectMessageRankViewController: UIViewController {
    
    private lazy var mainView: PaidDirectMessageRankView = {
        let view = PaidDirectMessageRankView().loadViewFromNib() as! PaidDirectMessageRankView
        view.delegate = self
        return view
    }()
    
    var interactor: IPaidDirectMessageRankInteractor!
    var router: IPaidDirectMessageRankRouter!
    private lazy var timestampStorage = TimestampStorage()
    let handleTapPatnerProfile: (String?) -> Void
    let handleTapHashtag: (String?) -> Void
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        interactor.requestChatRank()
    }
    
    public init(handleTapPatnerProfile: @escaping (String?) -> Void, handleTapHashtag: @escaping (String?) -> Void) {
        self.handleTapPatnerProfile = handleTapPatnerProfile
        self.handleTapHashtag = handleTapHashtag
        super.init(nibName: "PaidDirectMessageRankViewController", bundle: SharedBundle.shared.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = mainView
    }
}

extension PaidDirectMessageRankViewController: PaidDirectMessageRankViewDelegate {
    func didSelectUser(id: String) {
        
        guard !id.isEmpty else {
            DispatchQueue.main.async { self.presentAlert(title: "User not found", message: "User not found, please try again..") }
            return
        }
        
        guard id != UserManager.shared.accountId else { return }
        
        DispatchQueue.main.async { KKDefaultLoading.shared.show() }
        interactor.createGroupChannel(selectedId: id)
    }
}

extension PaidDirectMessageRankViewController: IPaidDirectMessageRankViewController {
    func displayChatRank(users: [RemoteChatRankData]) {
        guard users.count >= 3 else {
            mainView.users = []
            return
        }
        
        mainView.users = Array(users.suffix(from: 3))
        mainView.topUsers = Array(users.prefix(3))
    }
    
    func displayError(message: String) {
        DispatchQueue.main.async {
            KKDefaultLoading.shared.hide()
            self.presentAlert(title: "Error", message: message)
        }
        
    }
    
    func displayCreateChannel(channel: GroupChannel?) {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
        
        guard let channel = channel else {
            DispatchQueue.main.async {
                self.presentAlert(title: "Error", message: "Failed to create channel, please try again..")
            }
            return
        }
        
        router.navigateToConversation(channel: channel, timestampStorage: timestampStorage, targetMessageForScrolling: channel.lastMessage, handleTapPatnerProfile: handleTapPatnerProfile)
    }
}
