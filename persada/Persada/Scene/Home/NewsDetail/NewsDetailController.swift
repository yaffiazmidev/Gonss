//
//  NewsDetailController.swift
//  Persada
//
//  Created by Muhammad Noor on 06/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import WebKit
import Combine
import CombineCocoa

class NewsDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
    private var contentHeight : CGFloat = 0.0
	// MARK: - Private Property
	
	private var newsDetail: NewsDetail?
	private var viewModel: NewsDetailViewModel?
	private var networkModel: FeedNetworkModel = FeedNetworkModel()
	private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
	private var tableView = UITableView()
	private var safeArea : UILayoutGuide!
	private var imagePost : AGVideoPlayerView?
	var index : IndexPath?
	var cellStatus : StatusNewsDetailCell?
    var onCommentChange : (Int) -> ()  = {_ in }
	// MARK: - Public Method
	
    convenience init(viewModel: NewsDetailViewModel) {
		self.init()
		
		self.viewModel = viewModel
		bindViewModel()
	}
    
	override func viewDidAppear(_ animated: Bool) {
		
		self.presentedViewController?.additionalSafeAreaInsets = view.safeAreaInsets
		super.viewDidAppear(animated)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.tabBarController?.tabBar.isHidden = true
        
        let backButton = UIBarButtonItem(image: UIImage(named: .get(.iconBack))?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleBack))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		safeArea = view.layoutMarginsGuide
		view.backgroundColor = .white
		setupTableView()
		self.navigationController?.interactivePopGestureRecognizer?.delegate = self
		createNotificationObservers()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MARK: - Private Method
	
	private func setupTableView() {
		view.addSubview(tableView)
		self.tableView.anchor(top: safeArea.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingBottom: -34)
		self.tableView.backgroundColor = .white
		self.tableView.rowHeight = UITableView.automaticDimension
		self.tableView.estimatedRowHeight = 1000
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.separatorStyle = .none
		self.tableView.tableFooterView = UIView()
		self.tableView.registerCustomCell(NewsDetailHeaderCell.self)
		self.tableView.registerCustomCell(NewsDetailCell.self)
		self.tableView.registerCustomCell(StatusNewsDetailCell.self)
		self.tableView.registerCustomCell(DetailItemUsernameTableViewCell.self)
        self.tableView.registerCustomCell(NewsDetailSeeSourceButton.self)
        self.tableView.registerCustomCell(BlankCell.self)
        self.tableView.bounces = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		if let image = imagePost {
			image.stop()
		}
	}
	
	func commentHandler(index: IndexPath) {
		
		if AUTH.isLogin(){
			guard let data = self.viewModel?.newsDetail, let newsId = data.id else {
				return
			}

            let comment = CommentDataSource(id: newsId, isNews: true)
            let controller = NewsCommentViewController(commentDataSource: comment)
            controller.bindNavigationBar(.get(.commenter), true)
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: false)
		} else {
			self.showPopUp()
		}
		
	}
    
    func routeToComment(updateLike : @escaping (Bool, Int) -> (), updateComment : @escaping (Int) -> (), isDeleted : @escaping () -> ()) {
        
        if AUTH.isLogin(){
            guard let data = self.viewModel?.newsDetail, let newsId = data.id else {
                return
            }

            let comment = CommentDataSource(id: newsId)
            let commentController = CommentViewController(commentDataSource: comment)
            commentController.bindNavigationBar(.get(.commenter), true)
            commentController.hidesBottomBarWhenPushed = true
            commentController.likeChange = { isLike, count in
                updateLike(isLike, count)
            }
            commentController.commentChange = { count in
                updateComment(count)
            }
            commentController.deleteFeed = {
                isDeleted()
            }
            
            self.navigationController?.pushViewController(commentController, animated: true)
        } else {
            self.showPopUp()
        }
    }
	
	func sharedHandler() {
		// TODO : Aktifkan bila dipake lagi, tambah isNews di CustomShareItem
//		guard let data = self.viewModel?.newsDetail else {
//			return
//		}
//
//        guard let newsUrl = data.postNews?.fullUrl else { return }
//        let text =  "KIPASKIPAS NEWS \n\n\(data.postNews?.headline ?? "") \n\n\nKlik link berikut untuk membuka tautan: \(newsUrl)"
//        guard let url = data.postNews?.thumbnailUrl else { return }
//        let vc = makeCustomShare(url: url, message: text, isNews: true)
//        self.present(vc, animated: true, completion: nil)
	}
	
	@objc func handleBack() {
		self.navigationController?.popViewController(animated: true)
	}
	
	private func bindViewModel() {
		
		viewModel?.changeHandler = { [weak self] change in
			guard let self = self else {
				return
			}
			
			switch change {
				
			case .didUpdateNewsDetail:
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			case .didEncounterError(let error):
				print(error.debugDescription)
			case .didLikeNews:
				guard let _ = self.viewModel?.newsDetail?.id else {
					return
				}
				
				self.viewModel?.$newsDetail.receive(on: DispatchQueue.global(qos: .userInteractive)).sink(receiveValue: { ( value: NewsDetail?) in
					self.viewModel?.newsDetail?.isLike = true
				}).store(in: &self.subscriptions)

//				self.viewModel?.fetchDetailNews(id: id)
			case .didUnlikeNews:
				guard let _ = self.viewModel?.newsDetail?.id else {
					return
				}
				
				self.viewModel?.$newsDetail.receive(on: DispatchQueue.global(qos: .userInteractive)).sink(receiveValue: { ( value: NewsDetail?) in
					self.viewModel?.newsDetail?.isLike = false
				}).store(in: &self.subscriptions)

//				self.viewModel?.fetchDetailNews(id: id)
			}
		}
	}
	
}

extension NewsDetailController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
					return true
	}

	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 6
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		var data = viewModel?.getCellViewModel()
		switch row {
		case 0:
			let cell = tableView.dequeueReusableCustomCell(with: NewsDetailHeaderCell.self, indexPath: indexPath)
			cell.selectionStyle = .none
			cell.backgroundColor = .white
			guard let post = data?.postNews else {
				return cell
			}
			imagePost = cell.imagePost
            let thumb = post.thumbnailUrl ?? ""
			cell.configure(
				title: post.title ?? "",
				date: "\(TimeFormatHelper.epochConverter(date: "", epoch: Double(data?.createAt ?? 0 * 1000), format: "dd MMMM yyyy"))",
				source: post.siteReference ?? "",
                mediaURL: post.medias?.first?.url ?? thumb,
                type: post.medias?.first?.type ?? "image", thumbnail: post.medias?.first?.url ??  thumb)
			
			return cell
		case 2:
			let cell = tableView.dequeueReusableCustomCell(with: NewsDetailCell.self, indexPath: indexPath)
            let content = data?.postNews?.content ?? ""
            
            let final = """
                <html>
                <head>
					<link href='https://fonts.googleapis.com/css?family=Roboto' rel='stylesheet'>
                    <meta name="viewport"  content="width=device-width, initial-scale=1, maximum-scale=1"/>
                    <style>
                        img {
                            width:auto;
                            height:auto;
                            max-width:100%;
                        }
                        iframe {
                            width:auto;
                            height:auto;
                            max-width:100%;
                        }

						p {
							font-family: Roboto;
							font-style: normal;
							font-weight: 200;
							font-size: 18px;
							line-height: 30px;
						}
                    </style>
                </head>
            <body>
                \(content)
            </body>
            </html>
"""
            cell.cellDelegate = self
            cell.webView.loadHTMLString(final, baseURL: Bundle.main.bundleURL)
			cell.selectionStyle = .none
			cell.backgroundColor = .white
			
			return cell
			
		case 3 :
			let cell = tableView.dequeueReusableCustomCell(with: StatusNewsDetailCell.self, indexPath: indexPath)
			cellStatus = cell
			cell.selectionStyle = .none
			cell.backgroundColor = .white
			let likes = String(data?.likes ?? 0)
			let comments =  String(data?.comments ?? 0)
			cell.set(likes: likes, comments: comments, isLike:  viewModel?.newsDetail?.isLike ?? false)
			
			cell.commentHandler = { [weak self] in
                self?.routeToComment { bool, totalLike in
                    cell.updateLike(isLike: bool, total: totalLike)
                } updateComment: { total in
                    DispatchQueue.main.async {
                        cell.commentLabel.text = "\(total)"
                    }
                    self?.onCommentChange(total)
                } isDeleted: {
                    //
                }
			}
			cell.sharedHandler = self.sharedHandler
			cell.likeHandler = { [weak self] in
				if AUTH.isLogin(){
					guard let status = data?.statusLike else { return }
					if status == "like" {
						let isLike = false
						var likes = data?.likes
						if likes ?? 0 > 0 {
							likes! -= 1
						}
						self?.viewModel?.requestUnlike()
						if let idx = self?.index {
							let dataDict : [String:Any] = ["index" : idx, "isLike" : isLike, "likes": likes ?? 0]
							NotificationCenter.default.post(name: newsCellUpdateNotifKey, object: nil, userInfo: dataDict)
						}
						cell.updateLike(isLike : isLike, total : likes!)
						data?.likes = likes
						data?.isLike = isLike
					} else if ( status == "unlike") {
						let isLike = true
						var likes = data?.likes
						if likes ?? 0 >= 0 {
							likes! += 1
						}
						self?.viewModel?.requestLike()
						if let idx = self?.index {
							let dataDict : [String:Any] = ["index" : idx, "isLike" : isLike, "likes": likes ?? 0]
							NotificationCenter.default.post(name: newsCellUpdateNotifKey, object: nil, userInfo: dataDict)
						}
						cell.updateLike(isLike : isLike, total : likes!)
						data?.likes = likes
						data?.isLike = isLike
					}
				} else {
					self?.showPopUp()
				}
		
			}

			return cell
			
        case 5:
            let cell = tableView.dequeueReusableCustomCell(with: NewsDetailSeeSourceButton.self, indexPath: indexPath)
            cell.configure(url: data?.postNews?.linkReference ?? "")
            return cell
        case 4:
            let cell = tableView.dequeueReusableCustomCell(with: BlankCell.self, indexPath: indexPath)
            return cell
		default:
			let attributedStringEditor = "Penyunting".appendStringWithAtribute(string: "  \(data?.postNews?.editor ?? "")", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12)])

			let attributedStringPublisher = "\nPenulis".appendStringWithAtribute(string: "  \(data?.postNews?.author ?? "")", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12)])

			let desc = NSMutableAttributedString()
			desc.append(attributedStringEditor)
			desc.append(attributedStringPublisher)
			let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 8
			desc.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, desc.length))

			let cell = tableView.dequeueReusableCustomCell(with: DetailItemUsernameTableViewCell.self, indexPath: indexPath)
			cell.selectionStyle = .none
			cell.descriptionLabel.font = .Roboto(.regular, size: 12)
			cell.descriptionLabel.textColor = .black
			cell.descriptionLabel.textAlignment = .left
			cell.descriptionLabel.attributedText = desc
			cell.backgroundColor = .white
			
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let row = indexPath.row
		
		switch row {
		case 0: return 430
		case 1: return 90
        case 3: return 56
        case 2: return contentHeight
        case 4: return 80
        case 5: return 90
		default: return UITableView.automaticDimension
		}
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 3 {
			print("lihat sumber")
		}
	}
	
	func showPopUp(){
			let popup = AuthPopUpViewController(mainView: AuthPopUpView())
			popup.modalPresentationStyle = .overFullScreen
			present(popup, animated: false, completion: nil)
        
        popup.handleWhenNotLogin = {
            popup.dismiss(animated: false, completion: nil)
        }
	}
	
    
}

extension NewsDetailController : UpdateNewsDetailHeightProtocol {
    func updateHeight(height: CGFloat) {
        contentHeight = height
        
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
    }
    
	func updateHeightOfRow(_ cell: NewsDetailCell, _ textView: UITextView) {
		let size = tableView.bounds.size
		let newSize = tableView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
		
		if size.height != newSize.height {
			UIView.setAnimationsEnabled(false)
			tableView.beginUpdates()
			tableView.endUpdates()
			UIView.setAnimationsEnabled(true)
			if let thisIndex = tableView.indexPath(for: cell) {
				tableView.scrollToRow(at: thisIndex, at: .bottom, animated: true)
			}
		}
	}
}



let newsDetailUpdateNotifKey = Notification.Name(rawValue: "newsDetailUpdateNotifKey")
let newsDetailUpdateCommentNotifKey = Notification.Name(rawValue: "newsDetailUpdateCommentNotifKey")
extension NewsDetailController {
	
	func createNotificationObservers(){
		NotificationCenter.default.addObserver(self, selector: #selector(updateLike(notification:)), name: newsDetailUpdateNotifKey, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateCommentCounter(notification:)), name: newsDetailUpdateCommentNotifKey, object: nil)
	}
	
	@objc
	func updateLike(notification: NSNotification){
		print("UPDATE LIKE nih ")
		if let isLike = notification.userInfo?["isLike"] as? Bool, let likes = notification.userInfo?["likes"] as? Int {

			cellStatus?.updateLike(isLike: isLike, total: likes)
			
			if let validIndex = self.index {
				let dataDict : [String:Any] = ["index" : validIndex, "isLike" : isLike, "likes": likes]
				NotificationCenter.default.post(name: newsCellUpdateNotifKey, object: nil, userInfo: dataDict)
			}
		}
	}
	
	@objc
	func updateCommentCounter(notification: NSNotification){
		if let comment = notification.userInfo?["comments"] as? Int, let index = notification.userInfo?["index"] as? IndexPath {
			let cell = tableView.dequeueReusableCustomCell(with: StatusNewsDetailCell.self, indexPath: index)

			cell.commentLabel.text = "\(comment)"
			
			if let validIndex = self.index {
				let dataDict : [String:Any] = ["index" : validIndex, "comments": comment]
				NotificationCenter.default.post(name: newsCellUpdateCommentNotifKey, object: nil, userInfo: dataDict)
			}
		}
	}

}


