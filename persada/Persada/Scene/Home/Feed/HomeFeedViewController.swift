//
//  NewSelebViewController2.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 07/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import ContextMenu
import KipasKipasShared

class HomeFeedViewController: BaseFeedViewController, NewSelebDisplayLogic {
    
	func displayViewModel(_ viewModel: FeedModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				case .story(let viewModel):
					self.displayStorysResult(viewModel)
				case .like(let viewModel):
					self.changeLike(viewModel)
				case .follow(let viewModel):
					self.changeFollow(viewModel)
				case .postStory(_):
					print("post story")
				case .media(_):
					print("print media")
				case .paginationSeleb(let data):
					self.displayPaginationSeleb(data)
				case .detail(let viewModel):
					self.displayDetailProfile(viewModel)
				case .unlike(let viewModel):
					self.changeLike(viewModel)
			case .emptyProfile:
				self.emptyProfile()
            case .failedToRefreshToken:
                self.handleFailedToRefreshToken()
			}
		}
	}


	private var router: NewSelebRouting!
	private var interactor: NewSelebInteractable!
	var presenter: HomeFeedPresenter!

    var firstEnter = true

    required init(mainView: BaseFeedView, dataSource: FeedModel.DataSource, feed: [Feed]) {
		super.init(view: mainView)
		self.presenter = HomeFeedPresenter(self)
        self.presenter.requestedPage = feed.isEmpty ? 0 : 1
//        self.presenter.feedsDataSource.accept(feed)
		setupFeedPresenter(presenter: presenter)
		router = NewSelebRouter(self)
		interactor = NewSelebInteractor(viewController: self, dataSource: dataSource)
	}


	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	required init(view: BaseFeedView) {
		fatalError("init(view:) has not been implemented")
	}

	override func loadView() {
		view = mainView
		mainView.delegate = self

	}

	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
        deleteDelegate = self
		
        refreshUI()
		self.mainView.tableView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
			let items = self.presenter.feedsDataSource.value
//            print("---\(indexPath.row) \(items.count - 1) \(self.presenter._loadingState.value)")
//			if indexPath.row == items.count - 1 && self.presenter._loadingState.value == false {
//				self.presenter.getNetworkFeed()
//			}
		}).disposed(by: disposeBag)
		
        addUploadProgressStory()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWillEnterForeground), name: .notifyWillEnterForegroundFeed, object: nil)
	}

    @objc
    func refreshWillEnterForeground(){
        refreshUI()
    }
    
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
        view.bringSubviewToFront(vw_upload)
	}
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
	
	//MARK::BUGFIX - Add ViewwillAppear Check Stories / Reload
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFeedNavigationbarTransparent()
        mainView.collectionView.reloadData()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setFeedNavigationbarTransparent()
    }
    
    private func setFeedNavigationbarTransparent(){
        navigationController?.navigationBar.backgroundColor = .clear
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = .clear
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.standardAppearance = coloredAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
        navigationController?.navigationBar.backgroundColor = .clear
    }

	func setup() {
        getStory()
//		presenter.getNetworkFeed()


	}
    
    func getStory() {
        guard AUTH.isLogin() else {
            interactor.doRequest(.publicStory(page: 0))
            return
        }
        
        if let story = StorySimpleCache.instance.getStories, !story.isEmpty {
            interactor.dataSource.dataStory = story
            print("FROM CACHE FEEDS 0")
            mainView.collectionView.reloadData()
        } else {
            interactor.doRequest(.story(page: 0))
        }
        NotificationCenter.default.post(name: notificationStoryData, object: nil)
    }
    
    func showPopUp(){
        DispatchQueue.main.async {
            let popup = AuthPopUpViewController(mainView: AuthPopUpView())
            popup.modalPresentationStyle = .overFullScreen
            popup.dismiss = {
                self.mainView.tableView.reloadData()
            }
            self.present(popup, animated: false, completion: nil)
            
            popup.handleWhenNotLogin = {
                popup.dismiss(animated: false, completion: nil)
            }
        }
    }
    
	func sharedFeed(_ feed: Feed?) {
        let text =  "\(feed?.account?.name ?? "KIPASKIPAS") \n\n\(feed?.post?.postDescription ?? "") \n\n\nKlik link berikut untuk membuka tautan:  \(APIConstants.webURL)/feed/\(feed?.id ?? "")"
        guard let url = feed?.post?.medias?.first?.url, let accountId = feed?.account?.id else { return }
        let item = CustomShareItem(message: text, type: .content, assetUrl: url, accountId: accountId)
        let vc = KKShareController(mainView: KKShareView(), item: item)
        self.present(vc, animated: true, completion: nil)
	}


	override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 60)
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let items = self.interactor.dataSource.dataStory else {
            return 0
        }
        return items.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let row = indexPath.row
        var cell = collectionView.dequeueReusableCustomCell(with: StoryItemCell.self, indexPath: indexPath)

        guard let items = self.interactor.dataSource.dataStory else {
            return cell
        }
        
        setupStoryCell(cell: &cell, items: items, row: row)

        return cell
	}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(horizontal: 10, vertical: 0)
    }
    
    //MARK:- Upload Story

    func uploadStory(_ prod: Product?, _ item: KKMediaItem, _ data: Data?){
        vw_upload.uploadStory(prod, item, callback: {
            self.toggleHeaderView()
        })
    }
    
    private func addUploadProgressStory(){
        vw_upload.actionFinishUpload = {
            self.getStory()
            NotificationCenter.default.post(name: .notificationUpdateProfile, object: nil, userInfo: nil)
            if self.vw_upload.latestUploadType == .story {
                self.presenter.getNetworkFeed()
            } else {
                self.cachedHeight.removeAll()
                self.presenter.getMyLatestFeed()
            }
            DispatchQueue.main.async {
                self.toggleHeaderView()
                self.mainView.tableView.reloadData()
            }
        }
        
        vw_upload.stopUpload = {
            DispatchQueue.main.async {
                self.toggleHeaderView()
            }
        }
    }
    
    private func toggleHeaderView() {
        if mainView.tableView.tableHeaderView == nil {
                mainView.tableView.sectionHeaderHeight = 40
                mainView.tableView.tableHeaderView = vw_upload
                mainView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                mainView.tableView.setContentOffset( CGPoint(x: 0, y: 0) , animated: true)
            } else {
                mainView.tableView.sectionHeaderHeight = 0
                mainView.tableView.tableHeaderView = nil
                mainView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                mainView.tableView.setContentOffset( CGPoint(x: 0, y: 0) , animated: true)
            }
        }
    
    private let vw_upload : UploadingStoryView = {
        let v = UploadingStoryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        v.translatesAutoresizingMaskIntoConstraints = true
        return v
    }()
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - NewSelebViewDelegate
extension HomeFeedViewController: BaseFeedViewDelegate, BaseFeedViewControllerDelegate, BaseFeedDeleteDelegate {

    func onFeedDeleted(feedID: String) {
        NotificationCenter.default.post(name: .notifyRemoveDataAfterDelete, object: nil, userInfo: ["feedID": feedID])
    }
    
	func handleEditPost() {
		
	}
    
	func handleShareFeedClicked(feed: Feed) {
        if AUTH.isLogin(){
            self.sharedFeed(feed)
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
		self.interactor.doRequest(.detail(username: mention))
	}
	
	func handleHashtagClicker(hashtag: String) {
		print("hastag > #", hashtag)
	}
    
    func handleLikeFeedClicked(feed: Feed, row: Int) {
        if !AUTH.isLogin(){
            showPopUp()
        }
    }

	func handleCommentClicked(feed: Feed, row: Int) {
        if AUTH.isLogin(){
            self.routeToComment(feed.id ?? "", feed, updateLike: { isLike, count in
                var value = self.presenter.feedsDataSource.value
                value[row].likes = count
                value[row].isLike = isLike
                self.presenter.feedsDataSource.accept(value)
            }, updateComment: { count in
                var value = self.presenter.feedsDataSource.value
                value[row].comments = count
                self.presenter.feedsDataSource.accept(value)
            }, isDeleted: {
                var value = self.presenter.feedsDataSource.value
                value.remove(at: row)
                self.presenter.feedsDataSource.accept(value)
            })
        } else {
            showPopUp()
        }
	}


	func calculateLike(like value: Int) {
		guard let index = interactor.dataSource.index else {
			return
		}
		self.presenter.updateFeedLikes(likes: value, index: index)
	}

	func calculate(comment value: Int) {
		guard let index = interactor.dataSource.index else {
			return
		}
		self.presenter.updateFeedComment(comments: value, index: index)
	}


	func refreshUI() {
        RefreshToken.shared.refreshToken(token: getRefreshToken()) { [weak self] status in
            self?.refresh()
        }
	}
    
    func refresh() {
        StorySimpleCache.instance.saveStories(stories: [])
        getStory()
        interactor.setPage(data: 0)
        presenter.lastPage = 0
        presenter.requestedPage = 0
        presenter.getNetworkFeed()
    }

	func gallery() {
		
		router.routeTo(.gallery(value: interactor))
	}

	func showFollowing() {
		router.routeTo(.showFollowing)
	}

	func showNews() {
		router.routeTo(.showNews)
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	private func setupStoryCell( cell: inout StoryItemCell, items: [StoriesItem], row: Int) {

		cell.item = items[row]
        
        for gesture in cell.addStoryButton.gestureRecognizers! {
            gesture.removeTarget(self, action: nil)
        }
        
        if row == 0 && AUTH.isLogin() {
            if cell.item.account?.id == getIdUser() {
                cell.subtitleLabel.textColor = .white
            } else  {
                if cell.item.account?.photo != nil {
                    cell.subtitleLabel.textColor = .white
                } else {
                    cell.subtitleLabel.textColor = .contentGrey
                }
            }
            
            cell.titleLabel.text = ""
            cell.titleLabel.isHidden = false
            cell.subtitleLabel.text = "My\nStory".uppercased()
            cell.addStoryButton.iconPlusImage.isHidden = AUTH.isLogin() == true ? false : true
//            cell.addStoryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddStory)))
            cell.addGestureToDetail()
            cell.addStoryButton.iconPlusImage.isUserInteractionEnabled = true
            cell.addStoryButton.iconPlusImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddStory)))
        } else {
            cell.addStoryButton.gradientLayer.isHidden = false
            cell.addStoryButton.iconPlusImage.isUserInteractionEnabled = false
            cell.addStoryButton.iconPlusImage.isHidden = true
            cell.titleLabel.isHidden = false
            cell.subtitleLabel.text = ""
            cell.subtitleLabel.textColor = .black
            cell.addGestureToDetail()
        }
        
        guard items[row].stories?.count != 0 else {
            return
        }
        
		cell.handleDetailStory = {
            if AUTH.isLogin(){
                let story = items[row]
                if story.stories?.count ?? 0 > 0{
                let type = story.account?.isSeleb == false ? "social" : "seleb"

                    self.router.routeTo(.detailStory(id: story.id ?? "", accountId: story.account?.id ?? "", type: type, post: items, imageURL: story.account?.photo ?? "", index: row, inter: self.interactor))
                }
                else{
                    
                    self.router.routeTo(.gallery(value: self.interactor))
                }
            }
            else{
                let popup = AuthPopUpViewController(mainView: AuthPopUpView())
                popup.modalPresentationStyle = .overFullScreen
                self.present(popup, animated: false, completion: nil)
                
                popup.handleWhenNotLogin = {
                    popup.dismiss(animated: false, completion: nil)
                }
            }
		}

	}
}


extension HomeFeedViewController {


	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		let view = getHeaderView()

		return view
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 90
	}
    
    @objc func handleAddStory() {
        if AUTH.isLogin(){
            self.router.routeTo(.gallery(value: self.interactor))
        } else {
            let popup = AuthPopUpViewController(mainView: AuthPopUpView())
            popup.modalPresentationStyle = .overFullScreen
            present(popup, animated: false, completion: nil)
            
            popup.handleWhenNotLogin = {
                popup.dismiss(animated: false, completion: nil)
            }
        }
    }

}



// MARK: - Private Zone
private extension HomeFeedViewController {


	func getHeaderView() -> UIView {
        let safeAreaInset = self.view.safeAreaInsets
        let headerView = UIView.init(frame: CGRect.init(x: safeAreaInset.left, y: safeAreaInset.top, width: mainView.tableView.frame.width, height: 90))

		mainView.collectionView.delegate = self
		mainView.collectionView.dataSource = self

        headerView.backgroundColor = .green
		headerView.addSubview(mainView.collectionView)
        mainView.collectionView.fillSuperviewSafeAreaLayoutGuide()

		return headerView
	}

	func displayDetailProfile(_ viewModel: Profile) {

		guard let id = viewModel.id, let type = viewModel.accountType else {
			return
		}

		self.router.routeTo(.showProfile(id: id, type: type))
	}

	func emptyProfile() {
		self.router.routeTo(.emptyProfile)
	}


	func displayPaginationSeleb(_ viewModel: [Feed]) {

		DispatchQueue.global(qos: .background).async {
			self.interactor.dataSource.dataSeleb?.append(contentsOf: viewModel)
		}
		
		mainView.tableView.reloadData()
	}

	func displayStorysResult(_ viewModel: [StoriesItem]) {
		interactor.dataSource.dataStory?.removeAll()
		interactor.dataSource.dataStory = viewModel
		mainView.collectionView.reloadData()
	}

	func changeLike(_ viewModel: DefaultResponse) {

	}

	func changeFollow(_ viewModel: DefaultResponse) {
	}
    
    func handleFailedToRefreshToken() {
        DispatchQueue.main.async { Toast.share.show(message: .get(.sesiKedaluwarsa)) { [weak self] in self?.showPopUp() } }
    }
}


extension HomeFeedViewController : UploadDelegate {
    func onUploadCallBack(param: PostFeedParam) {
        vw_upload.uploadPost(param: param) {
            self.toggleHeaderView()
        }
    }
    
    
}
