//
//  ChannelContentsController.swift
//  Persada
//
//  Created by Muhammad Noor on 08/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import ContextMenu
import RxSwift
import RxCocoa

class ChannelContentsController: BaseFeedViewController {
    
	private let presenter: ChannelContentPresenter
	private let viewModel: ChannelContentsViewModel = ChannelContentsViewModel(networkModel: ChannelNetworkModel())
	private var selectedRowComment = 0
	private var router: ChannelContentRouting!
    
	var name: String = ""
    var index: Int?
    var feed: [Feed] = []
	var descriptionChannel: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
        setupNavigationBar()
        
        viewModel.fetchChannel()
        handleBind()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    required init(name: String, channelId: String, _ isFollow: Bool = false, presenter: ChannelContentPresenter, view: BaseFeedView, feedId: String? = nil){
        self.presenter = presenter
        super.init(view: view)
        self.setupFeedPresenter(presenter: presenter)
        self.router = ChannelContentRouter(self)
        
        self.presenter.channelId = channelId
        self.presenter.isFollow = isFollow
        self.presenter.selectedFeedId = feedId
        self.viewModel.channelId = channelId
        self.viewModel.isFollow = isFollow
        self.name = name
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    required init(view: BaseFeedView) { fatalError("init(view:) has not been implemented") }
    
    private func handleBind() {
        
        if let _ = index {
            presenter.getNetworkFeed()
        } else {
            presenter.feedsDataSource.accept(feed)
        }
        
        presenter.feedsDataSource.bind { [weak self] feed in
            guard let self = self else { return }
            self.mainView.tableView.reloadData()
        }.disposed(by: disposeBag)
        
        viewModel.changeHandler = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .didFollowChannel, .didUnFollowChannel:
                NotificationCenter.default.post(name: NSNotification.Name("handleUpdateChannelList"), object: nil)
                self.mainView.tableView.reload()
            case .didGetChannel:
                self.mainView.tableView.reload()
            default: break
            }
        }
        
        handlePlayFirstVideo()
    }
    
    func handlePlayFirstVideo(){
        self.mainView.tableView.isHidden = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.mainView.tableView.isHidden = false
            if let cell = self.mainView.tableView.visibleCells.first as? BaseFeedTableViewCell2 {
                _ = cell.playVideo()
            }
            
            if let cell = self.mainView.tableView.visibleCells.first as? BaseFeedMultipleTableViewCell {
                cell.selebCarouselView.playFirst()
            }
        }
    }
    
    override func loadView() {
        view = mainView
        mainView.tableView.registerCustomReusableHeaderFooterView(ChannelContentsHeaderView.self)
        mainView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func setupNavigationBar() {
        let reportButton = UIBarButtonItem(image: UIImage(named: String.get(.iconReport)), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = reportButton
    }
    
    func sharedFeed(_ feed: Feed?) {
        let text =  "\(feed?.account?.name ?? "KIPASKIPAS") \n\n\(feed?.post?.postDescription ?? "") \n\n\nKlik link berikut untuk membuka tautan: \(APIConstants.webURL)/feed/\(feed?.id ?? "")"
        guard let url = feed?.post?.medias?.first?.url, let accountId = feed?.account?.id else { return }
        let item = CustomShareItem(message: text, type: .content, assetUrl: url, accountId: accountId)
        let vc = KKShareController(mainView: KKShareView(), item: item)
//        CustomShareViewController(item: item)
        self.present(vc, animated: true, completion: nil)
    }
}

extension ChannelContentsController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return descriptionChannel == .get(.channelGeneral) ? 0 : 120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCustomHeaderFooterView(with: ChannelContentsHeaderView.self)
        cell.messageLabel.text = descriptionChannel
        cell.buttonFollow.setTitle(.get(viewModel.isFollow ? .unfollow : .follow), for: .normal)
        cell.buttonFollow.setup(color: viewModel.isFollow ? .gainsboro : .primary, textColor: .white, font: .Roboto(.regular, size: 12))
        
        cell.buttonFollow.rx.tap.asDriver().debounce(DispatchTimeInterval.milliseconds(500)).drive(onNext: { [weak self] (_) in
            guard let self = self else { return }
            
            if !AUTH.isLogin() {
                self.showPopUp()
                return
            }
            
            self.viewModel.isFollow ? self.viewModel.unfollowChannel() : self.viewModel.followChannel()
        }).disposed(by: disposeBag)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let items = presenter.feedsDataSource.value
        if indexPath.row == items.count - 1 && presenter._loadingState.value == false {
            presenter.getNetworkFeed()
        }
    }
}

extension ChannelContentsController: UIGestureRecognizerDelegate {}

extension ChannelContentsController: BaseFeedViewControllerDelegate {
    func showPopUp() {
        let popup = AuthPopUpViewController(mainView: AuthPopUpView())
        popup.modalPresentationStyle = .overFullScreen
        present(popup, animated: false, completion: nil)
        
        popup.handleWhenNotLogin = {
            popup.dismiss(animated: false, completion: nil)
        }
    }
    
    func handleDeletePost(id: String) {
        if AUTH.isLogin() {
            presenter.deleteFeedById(id: id, successDelete: {
                //handlesuccessdelete
            })
        } else {
            showPopUp()
        }
    }
    
    func handleEditPost() {
        
    }
    
    func handleLikeFeedClicked(feed: Feed, row: Int) {
        if !AUTH.isLogin(){
            showPopUp()
        }
    }
    
    func handleCommentClicked(feed: Feed, row: Int) {
        if AUTH.isLogin(){
            guard let id = feed.id else {
                return
            }
            self.selectedRowComment = row
            self.router.routeTo(.selectedComment(id: id, item: feed))
        } else {
            showPopUp()
        }
        
    }

    func handleShareFeedClicked(feed: Feed) {
        if AUTH.isLogin() {
            sharedFeed(feed)
        } else {
            showPopUp()
        }
        
    }

    func handleProfileClicked(id: String, type: String) {
        if AUTH.isLogin(){
            self.router.routeTo(.showProfile(id: id, type: type))
        } else {
            showPopUp()
        }
    }
    
    func handleMentionClicked(mention: String) {
        print("mention > @", mention)
        if !AUTH.isLogin() {
            showPopUp()
        }
    }
    
    func handleHashtagClicker(hashtag: String) {
        print("hastag > #", hashtag)
    }

    func calculate(comment value: Int) {
        self.presenter.updateFeedComment(comments: value, index: selectedRowComment)
        self.mainView.tableView.beginUpdates()
        guard let cell = self.mainView.tableView.cellForRow(at: IndexPath(item: selectedRowComment, section: 0)) as? BaseFeedTableViewCell2 else {return}
        cell.commentCounterLabel.text = String((Int(cell.commentCounterLabel.text ?? "0") ?? 0) + value)
        self.mainView.tableView.endUpdates()
    }

    func calculateLike(like value: Int) {
        self.presenter.updateFeedLike(likes: value, index: selectedRowComment)
        self.mainView.tableView.beginUpdates()
        guard let cell = self.mainView.tableView.cellForRow(at: IndexPath(item: selectedRowComment, section: 0)) as? BaseFeedTableViewCell2 else {return}
        cell.likeCounterLabel.text = String((Int(cell.likeCounterLabel.text ?? "0") ?? 0) + value)
        self.mainView.tableView.endUpdates()
    }
}

