//
//  ProfileDetailViewController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 08/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import ContextMenu
import RxCocoa
import RxSwift
import Combine

class ProfileDetailViewController : BaseFeedViewController {


	let presenter: ProfileDetailPresenter!
	var userProfileDelegate: NewUserProfileDelegate?
	var router: ProfileDetailRouting!
	var indexSelectedComment = 0
	let index: Int
	var showNavBar: Bool = false
	var subscriptions: Set<AnyCancellable> = []
	var fromHashtag = false
	var scrollTo = true
    var isDeletedClosure : (String) -> () = { _ in }


	required init(mainView: BaseFeedView, userId: String, index: Int, lastPage: Int, totalPage: Int = 0,_ feeds: [Feed] = []) {
		self.index = index
			self.presenter = ProfileDetailPresenter(userId: userId)
		self.presenter.requestedPage = lastPage
        self.presenter.totalPage = totalPage
		super.init(view: mainView)
		setupFeedPresenter(presenter: presenter)
		self.presenter.feedsDataSource.accept(feeds)
		self.presenter.counterFeed = presenter.feedsDataSource.value.count
		
		self.router = ProfileDetailRouter(self)
		}
	
	required init(mainView: BaseFeedView, hashtag: String, index: Int, lastPage: Int, feeds: [Feed]) {
		self.index = index
		self.presenter = ProfileDetailPresenter(userId: hashtag)
		self.presenter.requestedPage = (lastPage)
		super.init(view: mainView)
		
		setupFeedPresenter(presenter: presenter)
		
		self.presenter.feedsDataSource.accept(feeds)
		self.presenter.counterFeed = presenter.feedsDataSource.value.count
//		self.presenter.saveFeeds(feedNetwork: feeds, page: presenter.requestedPage)
		
		self.router = ProfileDetailRouter(self)
//		self.presenter.getNetworkHashtagFeed()
		
		self.fromHashtag = true
		}
	override func loadView() {
		view = mainView
        mainView.loading.startAnimating()
		setupNav()
		view.backgroundColor = .white
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}

	required init(view: BaseFeedView) {
		fatalError("init(view:) has not been implemented")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if fromHashtag {
			navigationController?.tabBarController?.tabBar.isHidden = true
		}
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.displayShadowToNavBar(status: true)
		navigationController?.interactivePopGestureRecognizer?.delegate = self
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        
        BaseFeedPreference.instance.isDetail = true
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        BaseFeedPreference.instance.isDetail = false
        BaseFeedPreference.instance.isScroll = false
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		
//		setup()
		delegate = self
        self.deleteDelegate = self

        print("FEEDS BEFORE \(self.presenter.feedsDataSource.value.count)")
        self.mainView.tableView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 ) {
            print("tes masuk sini")
            self.mainView.tableView.scrollToRow(at: IndexPath(row: self.index, section: 0), at: .middle, animated: false)
            self.mainView.tableView.isHidden = false
            print("FEEDS AFTER \(self.presenter.feedsDataSource.value.count)")
            self.mainView.loading.stopAnimating()
            BaseFeedPreference.instance.isScroll = true
		}
        
        self.mainView.tableView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
            let items = self.presenter.feedsDataSource.value
            
            if indexPath.row == items.count - 2 && self.presenter.requestedPage < self.presenter.totalPage {
                self.presenter.requestedPage += 1
                
                if self.fromHashtag {
                    self.presenter.getNetworkHashtagFeed()
                } else {
                    self.presenter.getNetworkFeed()
                }
            }
        }).disposed(by: disposeBag)
        
        mainView.tableView.rx.didEndDisplayingCell.bind { cell, index in
            if let cell = cell as? BaseFeedTableViewCell2  {
//                cell.video.stop()
//                cell.player.stop()
            }
            
            if let cell = cell as? BaseFeedMultipleTableViewCell  {
                cell.selebCarouselView.pauseAll()
            }
        }.disposed(by: disposeBag)
        
        mainView.tableView.rx.willDisplayCell.bind { cell, index in
            print("INDEX \(index.row)")
            if let cell = cell as? BaseFeedTableViewCell2  {
//                cell.video.isMuted = false
//                cell.player.stop()
            }
            
            if let cell = cell as? BaseFeedMultipleTableViewCell {
                cell.selebCarouselView.pauseAll()
            }
        }.disposed(by: disposeBag)
                
        presenter._loadingState.bind { (loading) in
            if !loading && self.mainView.tableView.isHidden == false {
                self.mainView.loading.stopAnimating()
                self.mainView.tableView.reloadData()
                return
            }
            if !self.mainView.loading.isAnimating {
                self.mainView.loading.startAnimating()
            }
            
        }.disposed(by: disposeBag)
	}
	
	func setup() {
		if fromHashtag {
			self.presenter.getNetworkHashtagFeed()
		} else {
			self.presenter.getNetworkFeed()
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}


extension ProfileDetailViewController: BaseFeedViewControllerDelegate, UIGestureRecognizerDelegate, BaseFeedDeleteDelegate {
    func onFeedDeleted(feedID: String) {
        isDeletedClosure(feedID)
    }
    
    
	func showPopUp() {
		let popup = AuthPopUpViewController(mainView: AuthPopUpView())
		popup.modalPresentationStyle = .overFullScreen
		present(popup, animated: false, completion: nil)
        
        popup.handleWhenNotLogin = {
            popup.dismiss(animated: false, completion: nil)
        }
	}
	
	func handleDeletePost(id: String) {
        self.presenter.deleteFeedById(id: id, successDelete: {
            //handlesuccessdelete
        })
	}
	
	func handleEditPost() {
		
	}
	
	func handleLikeFeedClicked(feed: Feed, row: Int) {

	}
	
	func handleCommentClicked(feed: Feed, row: Int) {
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

	}

	func handleShareFeedClicked(feed: Feed) {
		sharedFeed(feed)
	}

	func handleProfileClicked(id: String, type: String) {
        if AUTH.isLogin(){
            router.showProfile(id: id, type: type)
        } else {
            showPopUp()
        }
	}
	
	func handleMentionClicked(mention: String) {
		print("mention > @", mention)
		
		self.presenter.detail(mention).sink { completion in
			switch completion {
			case .failure(let error):
				if error is ErrorMessage {
					self.router.emptyProfile()
				} else {
					print(error.localizedDescription)
				}
			case .finished: break
			}
		} receiveValue: { model in
			guard let model = model.data else { return }
			
			self.router.showProfile(id: model.id ?? "", type: model.accountType ?? "")
		}.store(in: &subscriptions)
	}
	
	func handleHashtagClicker(hashtag: String) {
		print("hastag > #", hashtag)
	}


	func calculateLike(like value: Int) {
		self.presenter.updateFeedLikes(likes: value, index: presenter.selectedCommentIndex)
	}

	func calculate(comment value: Int) {
		self.presenter.updateFeedComment(comments: value, index: presenter.selectedCommentIndex)
	}

	func handleLike(_ feed: Feed)  {
		presenter.updateLikeFeed(feed)
	}

	func handleFollow(_ id: String)  {

	}

	func handleProfile(_ id: String, _ type: String) {
		let controller = AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id, type: type))
		controller.setProfile(id: id, type: type)
//		controller.bindNavigationBar("", false)
		
		let navigate = UINavigationController(rootViewController: controller)
		navigate.modalPresentationStyle = .fullScreen

		self.present(navigate, animated: true, completion: nil)
	}

	func handleComment(_ postId: String, _ feed: Feed) {
		router.routeToComment(postId, feed)
	}

	func sharedFeed(_ feed: Feed?) {
        let text =  "\(feed?.account?.name ?? "KIPASKIPAS") \n\n\(feed?.post?.postDescription ?? "") \n\n\nKlik link berikut untuk membuka tautan: \(APIConstants.webURL)/feed/\(feed?.id ?? "")"
        guard let url = feed?.post?.medias?.first?.url, let accountId = feed?.account?.id else { return }
        let item = CustomShareItem(message: text, type: .content, assetUrl: url, accountId: accountId)
        let vc = KKShareController(mainView: KKShareView(), item: item)
        self.present(vc, animated: true, completion: nil)
	}
	
	func setupNav(){
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)), style: .plain, target: self, action: #selector(self.back))
		self.navigationController?.navigationBar.tintColor = .white
	}
	
	@objc func back(){
		let validId = self.presenter.userId
		let showNavBar = self.showNavBar
		self.router.dismiss(validId, showNavBar)
	}

//	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		if((mainView.tableView.contentOffset.y >= (mainView.tableView.contentSize.height - mainView.tableView.frame.size.height)) && presenter.feedsDataSource.value.count > 0 && presenter._loadingState.value == false) {
//
//			print("requesting page \(presenter.requestedPage)")
//			self.userProfileDelegate?.updatePage(value: presenter.requestedPage)
//
//			if fromHashtag {
//				self.presenter.getNetworkHashtagFeed()
//			} else {
//				self.presenter.getNetworkFeed()
//			}
//		}
//	}
//
    
	
}

