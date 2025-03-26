//
//  NewsController.swift
//  Persada
//
//  Created by Muhammad Noor on 03/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Combine
import ContextMenu

class NewsController: UIViewController {
	
	let mainView = NewsView()
	let categoryRelay = BehaviorRelay<[NewsCategoryData]>(value: [])
	
	var newsList : [NewsCellViewModel] = []
    var newsWithCategoryList: [NewsViewModelCategory] = []
    
	let disposeBag = DisposeBag()
	
	private var subscriptions: Set<AnyCancellable> = []
	var viewModel: NewsViewModel?
	
	var timer = Timer()
	var counter = 0
	var isPaging = false
    
    var isAll = true
    var previousContentOffset: Int = 0
	var categoryID = ""
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewModel = NewsViewModel(networkNewsModel: NewsNetworkModel(), networkModel: FeedNetworkModel(), networkFollowModel: ProfileNetworkModel())
		bindDataSource()
		bindViewModel()
		bindOnClick()
		createNotificationObservers()
				
        
       
        categoryRelay.accept([NewsCategoryData(id: "", name: "", slug: "", totalNews: 0, selected: false)])
		categoryRelay.asObservable().bind(to: mainView.headerCategory.categoryCollectionView.rx.items(cellIdentifier: NewsCellIdentifier.newsCategoryIdentifier.rawValue, cellType: NewsCategoryCell.self)) {
			index, data, cell in
			cell.setUpCell(category: data)

		}.disposed(by: disposeBag)
        
        categoryRelay.asObservable().bind { [weak self] _ in
            self?.mainView.headerCategory.categoryCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .top)
            self?.categoryID = ""
        }.disposed(by: disposeBag)
		

		
		mainView.tableViewNews.refreshControl = mainView.refreshControl
		mainView.refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
	}
	
	func showPopUp(){
		let popup = AuthPopUpViewController(mainView: AuthPopUpView())
		popup.modalPresentationStyle = .overFullScreen
		present(popup, animated: false, completion: nil)
        
        popup.handleWhenNotLogin = {
            popup.dismiss(animated: false, completion: nil)
        }
	}
	@objc func handleRefresh() {
        self.isPaging = false
		self.viewModel?.currentPage = 0
        if categoryID.isEmpty {
            self.viewModel?.input.fetchTrendingNewsTrigger.send()
        } else {
            self.viewModel?.input.fetchNewsWithSelectedCategoryTrigger.send(self.categoryID)
        }
	}
    
    func handleRefreshAll() {
        self.isPaging = false
        self.viewModel?.currentPage = 0
        self.viewModel?.fetchTrendingNewsTrigger.send()
    }
	
	
	func bindOnClick() {
		mainView.headerCategory.categoryCollectionView.rx.modelSelected(NewsCategoryData.self).bind { [weak self] (category) in
            guard let self = self else { return }
			self.isPaging = false
			self.viewModel?.currentPage = 0
            if let id = category.id, !id.isEmpty {
                self.categoryID = id
                self.isAll = false
                
                if let row = self.newsWithCategoryList.firstIndex(where: {$0.id == self.categoryID}) {
                    if self.newsWithCategoryList[row].news.isEmpty {
                        self.mainView.startLoading()
                        self.viewModel?.input.fetchNewsWithSelectedCategoryTrigger.send(id)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.mainView.tableViewNews.scrollToRow(at: [0, 0], at: .top, animated: false) }
                        return
                    }
                    self.newsList = self.newsWithCategoryList[row].news
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.mainView.tableViewNews.scrollToRow(at: [0, 0], at: .top, animated: false) }
                    self.mainView.tableViewNews.reload()
                }
                return
            }
            
            self.isAll = true
            self.categoryID = ""
            if self.newsWithCategoryList.first?.news.isEmpty == true {
                self.mainView.startLoading()
                self.handleRefreshAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.mainView.tableViewNews.scrollToRow(at: [0, 0], at: .top, animated: false) }
                return
            }
            
            self.newsList = self.newsWithCategoryList.first?.news ?? []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.mainView.tableViewNews.scrollToRow(at: [0, 0], at: .top, animated: false) }
            self.mainView.tableViewNews.reload()
		}.disposed(by: disposeBag)
		
		mainView.headerCategory.searchButton.rx.tap.bind { (_) in
			let searchNewsController = SearchNewsController(mainView: SearchNewsView(), dataSource: SearchNewsModel.DataSource())
			
			searchNewsController.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(searchNewsController, animated: true)
		}.disposed(by: disposeBag)
		
	}
	
	
	override func loadView() {
		view = mainView
		mainView.tableViewNews.delegate = self
		mainView.tableViewNews.dataSource = self
	}
	
	private func bindDataSource() {
        self.viewModel?.input.fetchCategoryNewsTrigger.send()
		self.viewModel?.input.fetchTrendingNewsTrigger.send()
		
	}
	
	func bindViewModel() {
		
		viewModel?.output.cellViewModels.subscribe(on: DispatchQueue.global(qos: .background))
			.sink(receiveValue: { [weak self] (value: [NewsCellViewModel]) in
				guard let self = self else { return }
                guard let row = self.newsWithCategoryList.firstIndex(where: {$0.id == self.viewModel?.categoryId.value ?? "-"}) else { return }
                
				if self.isPaging {
                    self.newsWithCategoryList[row].news.append(contentsOf: value)
				} else {
                    self.newsWithCategoryList[row].news = value
				}
                
                self.newsList = self.newsWithCategoryList[row].news
                
                DispatchQueue.main.async {
                    self.mainView.tableViewNews.reload()
                    self.mainView.stopLoading()
                    self.mainView.refreshControl.endRefreshing()
                }
			}).store(in: &subscriptions)
		
		viewModel?.output.cellCategoryViewModels
			.sink(receiveValue: { [weak self] (values: [NewsCategoryData]) in
				guard let self = self else { return }
                var datas = values.filter { (news) -> Bool in news.totalNews != 0 }
                datas.insert(NewsCategoryData(id: "", name: "All", slug: "", totalNews: 0, selected: true), at: 0)
                datas.forEach { category in self.newsWithCategoryList.append(NewsViewModelCategory(id: category.id ?? "-", news: [])) }
                self.newsWithCategoryList.removeDuplicates()
				self.categoryRelay.accept(datas)
			}).store(in: &subscriptions)
		
	}
	
	private func handleProfile(_ id: String, _ type: String) {
		let profileController = ProfileSelebController(id: id, type: type, viewModel: ProfileViewModel(id: id, networkModel: ProfileNetworkModel()))
		self.present(profileController, animated: true, completion: nil)
	}
	
	private func handleComment(_ id: String, postId: String, index: IndexPath) {
        
        let comment = CommentDataSource(id: postId, isNews: true)
        let controller = NewsCommentViewController(commentDataSource: comment)
        controller.bindNavigationBar(.get(.commenter), true)
        controller.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(controller, animated: false)
	}
	
	private func handleShare(item : NewsCellViewModel) {
		
		let text =  "KIPASKIPAS NEWS \n\n\(item.title ?? "") \n\n\nKlik link berikut untuk membuka tautan: news.kipaskipas.com"
		
		let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
		
		self.present(activityController, animated: true, completion: nil)
	}
	
	deinit {
		viewModel = nil
		subscriptions.forEach { $0.cancel() }
		NotificationCenter.default.removeObserver(self)
	}
}


extension NewsController : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return newsList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = newsList[indexPath.row]
        
        let lastDigit = indexPath.row % 10
        
        if lastDigit == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsBiggerTopTitleViewCell") as! NewsBiggerTopTitleViewCell
            cell.setUpCell(item: data)
            return cell
        } else if lastDigit ==  9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTopTitleWithDescriptionViewCell") as! NewsTopTitleWithDescriptionViewCell
            cell.setUpCell(item: data)
            return cell
        } else if lastDigit == 3 ||  lastDigit == 6 {
            if data.imageList.count > 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewsMultipleImageViewCell") as! NewsMultipleImageViewCell
                cell.setUpCell(item: data)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsBottomTitleViewCell") as! NewsBottomTitleViewCell
            cell.setUpCell(item: data)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListViewCell") as! NewsListViewCell
        cell.setUpCell(item: data)
        return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = self.newsList[indexPath.row]
        let viewModel = NewsDetailViewModel(networkModel: FeedNetworkModel(), id: news.id ?? "", newsDetail: news.newsDetail)
        let controller = NewsDetailController(viewModel: viewModel)
        controller.onCommentChange = { [weak self] total in
            self?.newsList.remove(at: indexPath.row)
            news.comment = total
            news.newsDetail?.comments = total
            self?.newsList.insert(news, at: indexPath.row)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
        controller.bindNavigationBar("", true)
		bindNavigationBar()
		controller.hidesBottomBarWhenPushed = true
		controller.index = indexPath
		self.navigationController?.pushViewController(controller, animated: true)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == newsList.count - 5 {
                viewModel?.currentPage += 1
                isPaging = true
                if isAll {
                    viewModel?.fetchTrendingNewsTrigger.send()
                    return
                }
                viewModel?.fetchNewsTrigger.send()
		}
	}
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
            if velocity < -5 {
                headerView(isVisible: false)
            } else if velocity > 5 {
                headerView(isVisible: true)
            }
    }
    
    func headerView(isVisible: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.mainView.containerHeaderCategory.alpha = isVisible ? 1 : 0
        }
    }
}

let newsCellUpdateNotifKey = Notification.Name(rawValue: "newsCellUpdateNotifKey")
let newsCellUpdateCommentNotifKey = Notification.Name(rawValue: "newsCellUpdateCommentNotifKey")
extension NewsController {
	
	func createNotificationObservers(){
		NotificationCenter.default.addObserver(self, selector: #selector(updateLikeCell(notification:)), name: newsCellUpdateNotifKey, object: nil)
		
	  NotificationCenter.default.addObserver(self, selector: #selector(updateCommentCounterCell(notification:)), name: newsCellUpdateCommentNotifKey, object: nil)
	}
	
	@objc
	func updateLikeCell(notification: NSNotification){
		if let isLike = notification.userInfo?["isLike"] as? Bool, let index = notification.userInfo?["index"] as? IndexPath, let likes = notification.userInfo?["likes"] as? Int {
            let news = newsList[index.row]
			news.isLike = isLike
			news.likes = likes
			newsList.remove(at: index.row)
			newsList.insert(news, at: index.row)
			mainView.tableViewNews.reloadData()
		}
	}
	
	@objc
	func updateCommentCounterCell(notification: NSNotification){
		if let comment = notification.userInfo?["comments"] as? Int, let index = notification.userInfo?["index"] as? IndexPath {
            let news = newsList[index.row]
			news.comment = comment
			newsList.remove(at: index.row)
			newsList.insert(news, at: index.row)
			mainView.tableViewNews.reloadData()
		}
	}

}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension UITableView {
    func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.reloadData() }
    }
}
