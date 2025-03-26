//
//  BaseFeedViewController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 19/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import ContextMenu

protocol NewSelebDisplayLogic where Self: UIViewController {
    
    func displayViewModel(_ viewModel: FeedModel.ViewModel)
}

protocol BaseFeedZoomDelegate: AnyObject {
    func zoom(started: Bool)
}

protocol BaseFeedViewControllerDelegate: AnyObject {
    func calculate(comment value: Int)
    func calculateLike(like value: Int)
    func handleCommentClicked(feed: Feed, row: Int)
    func handleShareFeedClicked(feed: Feed)
    func handleLikeFeedClicked(feed: Feed, row: Int)
    func handleProfileClicked(id: String, type: String)
    func handleMentionClicked(mention: String)
    func handleHashtagClicker(hashtag: String)
    func showPopUp()
}

protocol BaseFeedDeleteDelegate : AnyObject {
    func onFeedDeleted(feedID: String)
}

public class BaseFeedViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AlertDisplayer {
    
    let mainView: BaseFeedView
    var basePresenter: BaseFeedPresenter!
    var cachedHeight: [String : CGFloat] = [:]
    private let networkReport = ReportNetworkModel()
    weak var delegate: BaseFeedViewControllerDelegate?
    weak var deleteDelegate: BaseFeedDeleteDelegate?
    var cell : BaseFeedMultipleTableViewCell?
    var cache = NSCache<NSString, NSNumber>()
    var indexToScroll: Int?
    var zoomDelegate: BaseFeedZoomDelegate?
    let popupReport = ReportPopupViewController(mainView: ReportPopupView())
    var bindCell = true
    
    required init(view: BaseFeedView) {
        self.mainView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFeedPresenter(presenter: BaseFeedPresenter) {
        self.basePresenter = presenter
        setupPresenter(presenter: basePresenter)
    }
    
    public override func viewDidLoad() {
        view.backgroundColor = .white
        mainView.tableView.separatorStyle = .none
        mainView.tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.appEnteredToBackground), name: UIScene.willDeactivateNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.appEnteredFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.updateLike(notification:)), name: likeFeedCommentNotifKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRow(_:)), name: .handleUpdateFeed, object: nil)
        
        setupObserveable()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var isDisappear = false
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isDisappear = true
        pauseVisibleVideos()
    }
    
    private func pauseVisibleVideos(){
        mainView.tableView.visibleCells.forEach { cell in
            if let cell = cell as? BaseFeedMultipleTableViewCell {
                cell.selebCarouselView.pauseAll()
            }
            
            if let cell = cell as? BaseFeedTableViewCell2 {
                cell.stopVideo()
            }
        }
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        self.isDisappear = false

        self.handlePlayingVideoByCellVisibility("viewDidAppear")
        
    }
    
    
    @objc
    func updateLike(notification: NSNotification) {
        if let feed = notification.userInfo?["feed"] as? Feed, let row = notification.userInfo?["row"] as? Int  {
            basePresenter.updateFeedLikesFromDetail(feed: feed, index: row)
            print(feed)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return basePresenter.feedsDataSource.value[collectionView.tag].post?.medias?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("**** basfeedvc.collectionView \(indexPath)")

        return UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: mainView.tableView.frame.width, height: 300)
    }
    
}


private extension BaseFeedViewController {
    
    @objc func appEnteredFromBackground() {
        
//        pausePlayeVideos(pause: false)
        
    }
    
    @objc func appEnteredToBackground() {
        
        //cellFirst = mainView.tableView.visibleCells.first as? BaseFeedTableViewCell2
        self.pausePlayeVideos(pause: true)
    }
    
    func refreshRow(_ row: Int) {
        UIView.performWithoutAnimation {
            self.mainView.tableView.beginUpdates()
//            if !basePresenter.expandedRow.contains(row) {
//                basePresenter.expandedRow.append(row)
//            }
            self.mainView.tableView.endUpdates()
        }
    }
    
    func checkExpandedRow(_ row: Int) -> Bool {
        return basePresenter.expandedRow.contains(row)
    }
    
    func getCurrentMultipleIndex(_ row: Int) -> Int {
        return basePresenter.currentMultipleIndex[row] ?? 0
    }
    
    func getCachedHeight(indexPath: Int, id: String) -> CGFloat {
        
        if let height = cachedHeight[id] {
            return height
        }
        let feed = basePresenter.feedsDataSource.value[indexPath]
        if let media = feed.post?.medias {
            if media.count > 1 {
                print("ID: \(id)")
                print("HEIGHT: \(media.first?.metadata?.height ?? "1920")")
                let height: Int = Int(media.first?.metadata?.height ?? "1920") ?? 1920
                let width: Int = Int(media.first?.metadata?.width ?? "1920") ?? 1920
//                let ratio = (CGFloat(width) / CGFloat(height))
                var newHeight = ((UIScreen.main.bounds.width * CGFloat(height)) / CGFloat(width))
                let acceptableHeight = UIScreen.main.bounds.height * 0.70
                       
                if newHeight > acceptableHeight {
                    newHeight = acceptableHeight
                }
                let multipleIndicatorHeight : CGFloat = 32.0
                newHeight = ceil( newHeight + multipleIndicatorHeight )

                cachedHeight[id] = newHeight
            } else {
                if let med = media.first {
                    // calculate the height for view
                    let height: Int = Int(med.metadata?.height ?? "1920") ?? 1920
                    let width: Int = Int(med.metadata?.width ?? "1920") ?? 1920
                    var newHeight = ((UIScreen.main.bounds.width * CGFloat(height)) / CGFloat(width))
                    let acceptableHeight = UIScreen.main.bounds.height * 0.70
                    
                    if newHeight > acceptableHeight {
                        newHeight = acceptableHeight
                    }
                    
                    newHeight = ceil( newHeight )
                    
                    print("HEIGHT \(String(describing: feed.post?.name)): \(newHeight)")
                    cachedHeight[id] = newHeight
                }
            }
        }
        
        return cachedHeight[id] ?? 0
        
    }
    
}

extension BaseFeedViewController: ReportFeedDelegate, PopupReportDelegate {
    func closePopUp(id: String, index: Int) {
        self.popupReport.dismiss(animated: false) {
//            self.basePresenter.deleteFeedById(id: id) {
//            }
            var value = self.basePresenter.feedsDataSource.value
            value.remove(at: index)
            self.basePresenter.feedsDataSource.accept(value)
        }
    }
    
    func reported() {
        DispatchQueue.main.async {
            self.popupReport.mainView.delegate = self
            self.popupReport.mainView.id = self.basePresenter.idFeed
            self.popupReport.mainView.index = self.basePresenter.indexFeed
            self.popupReport.modalPresentationStyle = .overFullScreen
            self.present(self.popupReport, animated: false, completion: nil)
        }
    }
}

extension BaseFeedViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.basePresenter.feedsDataSource.value.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let data = self.basePresenter.feedsDataSource.value
        let item = data[row]
        let feedId = data[row].id ?? ""
        if data[row].id ?? "" == data[0].id ?? "" || data[row].id ?? "" == data[1].id ?? "" {
            if data.count > row {
                self.basePresenter.updateFeedAlreadySeen(feedId: feedId) { isSuccess in
                    print("---\(isSuccess ? "Success" : "Failed") seen feed \(data[row].account?.name ?? "")")
                    if isSuccess {
                        FeedSimpleCache.instance.saveValue(key: feedId, value: true)
                    }
                }
            }
        }
        if (item.post?.medias?.count ?? 0) <= 1 {
            return self.getSingleFeedCell(tv: tableView, row: row, data: item)
        } else {
            return self.getMultipleFeedCell(tv: tableView, row: row, data: item)
        }
    }
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let videoCell = cell as? ASAutoPlayVideoLayerContainer, let _ = videoCell.videoURL {
//            ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
//        }
        print("%%% didEndDisplayingCell normal \(indexPath.row)")

        if let cell = cell as? BaseFeedTableViewCell2  {
            //cell.video.stop()
//                print("**** rx.didEndDisplaying - \(index.row) - \(cell.feed?.account?.username)")
            cell.stopVideo()
            cell.stopTimer()
        } else if let cell = cell as? BaseFeedMultipleTableViewCell {
            cell.stopTimer()
        }
        
        if let index = indexToScroll {
            cache.setObject(NSNumber(value: index), forKey: NSString(string: basePresenter.feedsDataSource.value[indexPath.row].post?.id ?? ""))
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("%%% scrollViewDidEndDecelerating")

        handlePlayingVideoByCellVisibility("Decelarating")
        mainView.tableView.visibleCells.forEach { cell in
            guard let indexPath = mainView.tableView.indexPath(for: cell) else { fatalError() }
            
            let cellRect = mainView.tableView.rectForRow(at: indexPath)
            let height = cellRect.height / 2
            let calculateCellRect = CGRect(x: cellRect.origin.x, y: cellRect.origin.y, width: cellRect.width, height: height)
            let completelyVisible = mainView.tableView.bounds.contains(calculateCellRect)
            
            let data = basePresenter.feedsDataSource.value
            
            if completelyVisible {
                print("@@@ lagi di \(cell) \(data[indexPath.row].account?.name ?? "")")
                if let cell = cell as? BaseFeedTableViewCell2 {
                    cell.startTimer()
                }
                
                if let cell = cell as? BaseFeedMultipleTableViewCell {
                    cell.startTimer()
                }
            } else {
                print("@@@ cell \(cell) \(data[indexPath.row].account?.name ?? "") ga keliatan")
                if let cell = cell as? BaseFeedTableViewCell2 {
                    cell.stopTimer()
                }
                
                if let cell = cell as? BaseFeedMultipleTableViewCell {
                    cell.stopTimer()
                }
            }
            
            let feedId = data[indexPath.row].id ?? ""
            if data.count > indexPath.row {
//                if let alreadySeen = FeedSimpleCache.instance.getValue(key: feedId) {
//                    print(alreadySeen)
//                } else {
//                    self.basePresenter.updateFeedAlreadySeen(feedId: feedId) { isSuccess in
//                        print("---\(isSuccess ? "Success" : "Failed") seen feed \(data[indexPath.row].account?.name ?? "")")
//                        if isSuccess {
//                            FeedSimpleCache.instance.saveValue(key: feedId, value: true)
//                        }
//                    }
//                }
                
                self.basePresenter.updateFeedAlreadySeen(feedId: feedId) { isSuccess in
                    print("---\(isSuccess ? "Success" : "Failed") seen feed \(data[indexPath.row].account?.name ?? "")")
                    if isSuccess {
                        FeedSimpleCache.instance.saveValue(key: feedId, value: true)
                    }
                }
            }
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("***** scrollViewDidEnd - Dragging")
        print("%%% scrollViewDidEndDragging")

        if !decelerate {
            handlePlayingVideoByCellVisibility("Dragging")
        }
    }
    
    @objc func pausePlayeVideos(pause: Bool = false){
//        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: mainView.tableView, appEnteredFromBackground: false, stopVideo: pause)
        let visibleCells = mainView.tableView.visibleCells
        
        if(visibleCells.count > 0){
            var cellFirst: BaseFeedTableViewCell2?
            var cellSecond: BaseFeedTableViewCell2?
            var cellThird: BaseFeedTableViewCell2?

            cellFirst = visibleCells[0] as? BaseFeedTableViewCell2
            cellFirst?.stopVideo()
            if(visibleCells.count > 1){
                cellSecond = visibleCells[1] as? BaseFeedTableViewCell2
                cellSecond?.stopVideo()
                if(visibleCells.count > 2){
                    cellThird = visibleCells[2] as? BaseFeedTableViewCell2
                    cellThird?.stopVideo()
                }
            }
        }
    }
    
    
    private func handlePlayingVideoByCellVisibility(_ event: String){
        if BaseFeedPreference.instance.isDetail {
            if BaseFeedPreference.instance.isScroll {
                self.playPlause(event)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                if BaseFeedPreference.instance.isScroll {
                    self.playPlause(event)
                }
            }
        } else {
            playPlause(event)
        }
        
            
    }
        
    
    func playPlause(_ event: String){
        if !isDisappear {
         
        if let cellFirst = mainView.tableView.visibleCells.first as? BaseFeedTableViewCell2 {
            guard let indexPath = mainView.tableView.indexPath(for: cellFirst) else { fatalError() }
            
            //let feedFirst = basePresenter.feedsDataSource.value[indexPath.row]
            var cellSecond: BaseFeedTableViewCell2?
            var cellThird: BaseFeedTableViewCell2?
            
            var cellSecondMultiple: BaseFeedMultipleTableViewCell?
            var cellThirdMultiple: BaseFeedMultipleTableViewCell?
            
            let visibleCells = mainView.tableView.visibleCells
            
            if(visibleCells.count > 1){
                if(visibleCells[1] is BaseFeedTableViewCell2){
                    cellSecond = (visibleCells[1] as? BaseFeedTableViewCell2)!
                } else if(visibleCells[1] is BaseFeedMultipleTableViewCell){
                    cellSecondMultiple = (visibleCells[1] as? BaseFeedMultipleTableViewCell)!
                }
                
                
                
            
                if(visibleCells.count > 2){
                    if(visibleCells[2] is BaseFeedTableViewCell2){
                        cellThird = (visibleCells[2] as? BaseFeedTableViewCell2)
                    } else if(visibleCells[2] is BaseFeedMultipleTableViewCell){
                        cellThirdMultiple = (visibleCells[2] as? BaseFeedMultipleTableViewCell)
                    }
                }
            }

            
            let cellRect = mainView.tableView.rectForRow(at: indexPath)
            if let superview = mainView.tableView.superview {
                let convertedRect = mainView.tableView.convert(cellRect, to:superview)
                let intersect = mainView.tableView.frame.intersection(convertedRect)
                let visibleHeight = intersect.height
                let cellHeight = cellRect.height
                let ratio = visibleHeight / cellHeight
                
                let RATIO_TO_SHOW = 0.5
                
//                print("***** \(event) - ratio first ", ratio, " - ", cellFirst.feed?.account?.username ?? "")
                
                if(ratio > RATIO_TO_SHOW){
                    if(cellFirst.playVideo()){
//                        print("***** \(event) - First - Play ", cellFirst.feed?.account?.username ?? "")
                        cellSecond?.stopVideo()
                        cellThird?.stopVideo()
                        cellSecondMultiple?.selebCarouselView.pauseAll()
                        cellThirdMultiple?.selebCarouselView.pauseAll()
                    }


                } else {
                    cellFirst.stopVideo()
                    cellThird?.stopVideo()
                    cellThirdMultiple?.selebCarouselView.pauseAll()
//                    print("***** \(event) - Second - Play ", cellSecond?.feed?.account?.username ?? "")
                    cellSecond?.playVideo()
                    cellSecondMultiple?.selebCarouselView.playFirst()
                }
            }
        } else if let cellFirst = mainView.tableView.visibleCells.first as? BaseFeedMultipleTableViewCell {
            guard let indexPath = mainView.tableView.indexPath(for: cellFirst) else { fatalError() }
            
            
            var cellSecondSingle: BaseFeedTableViewCell2?
            var cellThirdSingle: BaseFeedTableViewCell2?
            
            var cellSecond: BaseFeedMultipleTableViewCell?
            var cellThird: BaseFeedMultipleTableViewCell?
            
            
            let visibleCells = mainView.tableView.visibleCells
            
            if(visibleCells.count > 1){
                if(visibleCells[1] is BaseFeedMultipleTableViewCell){
                    cellSecond = (visibleCells[1] as? BaseFeedMultipleTableViewCell)!
                } else if(visibleCells[1] is BaseFeedTableViewCell2){
                    cellSecondSingle = (visibleCells[1] as? BaseFeedTableViewCell2)!
                }
            
                if(visibleCells.count > 2){
                    if(visibleCells[2] is BaseFeedMultipleTableViewCell){
                        cellThird = (visibleCells[2] as? BaseFeedMultipleTableViewCell)
                    }
                } else if(visibleCells[1] is BaseFeedTableViewCell2){
                    cellThirdSingle = (visibleCells[1] as? BaseFeedTableViewCell2)!
                }
            }

            
            let cellRect = mainView.tableView.rectForRow(at: indexPath)
            if let superview = mainView.tableView.superview {
                let convertedRect = mainView.tableView.convert(cellRect, to:superview)
                let intersect = mainView.tableView.frame.intersection(convertedRect)
                let visibleHeight = intersect.height
                let cellHeight = cellRect.height
                let ratio = visibleHeight / cellHeight
                
                let RATIO_TO_SHOW = 0.5
                
//                print("***** \(event) - ratio first ", ratio, " - ", cellFirst.feed?.account?.username ?? "")
                
                if(ratio > RATIO_TO_SHOW){
                    cellFirst.selebCarouselView.playFirst()
                    if(cellFirst.selebCarouselView.checkIsPlaying()){
//                        print("***** \(event) - First - Play ", cellFirst.feed?.account?.username ?? "")
                        cellSecond?.selebCarouselView.pauseAll()
                        cellThird?.selebCarouselView.pauseAll()
                        cellSecondSingle?.stopVideo()
                        cellThirdSingle?.stopVideo()
                        
                    }


                } else {
                    cellFirst.selebCarouselView.pauseAll()
                    cellThird?.selebCarouselView.pauseAll()
                    cellThirdSingle?.stopVideo()
//                    print("***** \(event) - Second - Play ", cellSecond?.feed?.account?.username ?? "")
                    cellSecond?.selebCarouselView.playFirst()
                    cellSecondSingle? .playVideo()
                }
            }
            
        }
        }
    }
    
    @objc func updateRow(_ notification: NSNotification) {
        guard let product = notification.userInfo?["updateProductDetailFromFeed"] as? Product, let index = notification.userInfo?["indexProductDetail"] as? Int else {
            return
        }
        var item = self.basePresenter.feedsDataSource.value
        item[index].post?.product = product
        self.basePresenter.feedsDataSource.accept(item)
    }

}

extension BaseFeedViewController {
    
    internal func handleReport(_ id: String, _ accountId: String, _ imageUrl: String, _ index: Int) {
        self.basePresenter.idFeed = id
        self.basePresenter.indexFeed = index
        if AUTH.isLogin(){
            if accountId == getIdUser() {
                present(deleteSheet(id, accountId, imageUrl, index), animated: true, completion: nil)
                return
            }
            present(reportSheet(id, accountId, imageUrl, index: index), animated: true, completion: nil)
        } else {
            let popup = AuthPopUpViewController(mainView: AuthPopUpView())
            popup.modalPresentationStyle = .overFullScreen
            present(popup, animated: false, completion: nil)
            
            popup.handleWhenNotLogin = {
                popup.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func reportSheet(_ id: String, _ accountId: String, _ imageUrl: String, index: Int) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: .get(.reportAndBlock), style: .default , handler:{ _ in
            self.networkReport.checkIsReportExist(.reportsExist(id: id)) { result in
                switch result {
                case .success(let isExist):
                    DispatchQueue.main.async {
                        if !(isExist.data ?? false) {
                            self.showReportController(id: id, imageUrl: imageUrl, accountId: accountId, index: index)
                        } else {
                            self.displayAlert(with: .get(.report), message: .get(.accountReported), actions: [UIAlertAction(title: .get(.ok), style: .cancel)])
                        }
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        self.displayAlert(with: .get(.error), message: err?.localizedDescription ?? "", actions: [UIAlertAction(title: .get(.ok), style: .cancel)])
                    }
                }
                
            }
        }))
        actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        return actionSheet
    }
    
    func deleteSheet(_ id: String, _ accountId: String, _ imageUrl: String, _ index: Int) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: .get(.deletePost), style: .default , handler:{ _ in
            self.basePresenter.deleteFeedById(id: id) {
            }
            var value = self.basePresenter.feedsDataSource.value
            value.remove(at: index)
            self.basePresenter.feedsDataSource.accept(value)
            actionSheet.dismiss(animated: true, completion: nil)
            self.deleteDelegate?.onFeedDeleted(feedID: id)
            
        }))
        actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        return actionSheet
    }
    
    private func showReportController(id: String, imageUrl: String, accountId: String, index: Int) {
        let reportController = ReportFeedController(viewModel: ReportFeedViewModel(id: id, imageUrl: imageUrl, accountId: accountId, indexFeed: index, networkModel: ReportNetworkModel()))
        reportController.delegate = self
        reportController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(reportController, animated: true)
    }
    
    private func getSingleFeedCell(tv: UITableView, row: Int, data: Feed) -> BaseFeedTableViewCell2 {
        let cell = tv.dequeueReusableCustomCell(with: BaseFeedTableViewCell2.self, indexPath: IndexPath.init(row: row, section: 0))
        
        let datas = basePresenter.feedsDataSource.value
        
        print("%%% getSingleFeedCell \(datas[row].account?.name)")
//        if datas[row].id == datas[0].id {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                cell.playVideo()
//                print("KE PLAY YA")
//            }
//        }
        
        
        cell.delegateZoom = self
        cell.row = row
        
        cell.handler = {  [weak self] row in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.refreshRow(row)
            } else {
                self.delegate?.showPopUp()
            }
        }
        
        cell.profileHandler = { [weak self] id, type in
            guard let self = self else { return }
            self.delegate?.handleProfileClicked(id: id, type: type)
        }
        
        cell.mentionHandler = { [weak self] (string) in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.delegate?.handleMentionClicked(mention: string)
            } else {
                self.delegate?.showPopUp()
            }
            
        }
        
        cell.hashtagHandler = {  [weak self] (string) in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.delegate?.handleHashtagClicker(hashtag: string)
                self.routeToHashtag(hashtag: string)
            } else {
                self.delegate?.showPopUp()
            }
        }
        
        cell.updateFeed = {  [weak self] (feed) in
            guard let self = self else { return }
            self.bindCell = false
            self.basePresenter.likeFeedRemote(feed: feed, index: row)
        }
        
        cell.commentHandler = {  [weak self] (item) in
            guard let self = self else { return }
            if !AUTH.isLogin() {
//                cell.video.isMuted = true
                cell.stopVideo()
            }
            self.delegate?.handleCommentClicked(feed: item, row: row)
        }
        
        cell.likeHandler = { [weak self] (item) in
            guard let self = self else { return }
            if !AUTH.isLogin() {
                //cell.video.isMuted = true
                cell.stopVideo()
            }
            self.delegate?.handleLikeFeedClicked(feed: item, row: row)
        }
        
        cell.reportHandler = { [weak self] id, accountId, imageURL in
            guard let self = self else { return }
            self.handleReport(id, accountId, imageURL, row)
        }
        cell.sharedHandler = { [weak self] in
            guard let self = self else { return }
            self.delegate?.handleShareFeedClicked(feed: data)
        }
        
        cell.seeProductHandler = { [weak self] in
            guard let self = self else { return }
            if AUTH.isLogin() {
                var product = data.post?.product
                product?.medias = data.post?.product?.medias
                product?.sellerName = data.post?.product?.sellerName
                self.routeToProductDetail(product: product!, index: row)
            } else {
                self.delegate?.showPopUp()
            }
        }
        
        cell.wikipediaHandler = { [weak self] url in
            guard let self = self else { return }
            self.routeToBrowser(url: url)
        }
        
        cell.shopHandler = { [weak self] id in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.routeToShop(id: id)
            } else {
                self.delegate?.showPopUp()
            }
        }
        
        cell.dmHandler = { [weak self] id in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.routeToDM(account: id)
            } else {
                self.delegate?.showPopUp()
            }
        }
//        print("URL ASLI DARI GAMBAR SINGLE \(String(describing: data.post?.name)): \(String(describing: data.post?.medias?[0].url))")
        cell.setup(feed: data, expanded: self.checkExpandedRow(row), height: self.getCachedHeight(indexPath: row, id: data.id ?? ""))
        return cell
    }
    
    private func getMultipleFeedCell(tv: UITableView, row: Int, data: Feed) -> BaseFeedMultipleTableViewCell {
        let cell = tv.dequeueReusableCustomCell(with: BaseFeedMultipleTableViewCell.self, indexPath: IndexPath.init(row: row, section: 0))
        cell.row = row
        cell.delegateZoom = self
        
        if let _ = basePresenter.feedsDataSource.value[row].post?.medias {
            if let cache = cache.object(forKey: (NSString(string: basePresenter.feedsDataSource.value[row].post?.id ?? ""))) {
                cell.indexScroll = cache.intValue
            }
            let width: CGFloat = UIScreen.main.bounds.width
            cell.selebCarouselView.view.frame = CGRect(x: 0, y: 0, width: width, height: 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let cellRect = self.mainView.tableView.rectForRow(at: IndexPath.init(row: row, section: 0))
                let completelyVisible = self.mainView.tableView.bounds.contains(cellRect)
                if completelyVisible {
                    if BaseFeedPreference.instance.isDetail {
                        if BaseFeedPreference.instance.isScroll {
                            if BaseFeedPreference.instance.isScroll {
                                cell.selebCarouselView.playFirst()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                if BaseFeedPreference.instance.isScroll {
                                    cell.selebCarouselView.playFirst()
                                }
                            }
                        }
                    } else {
                        cell.selebCarouselView.playFirst()
                    }
                }
            }

        }
        
        self.cell = cell
        
        cell.handler = { [weak self] row in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.refreshRow(row)
            } else {
                self.delegate?.showPopUp()
            }
        }
        
        cell.profileHandler = { [weak self] id, type in
            guard let self = self else { return }
            self.delegate?.handleProfileClicked(id: id, type: type)
        }
        
        cell.mentionHandler = { [weak self] string in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.delegate?.handleMentionClicked(mention: string)
            } else {
                self.delegate?.showPopUp()
            }
        }
        
        cell.hashtagHandler = { [weak self] string in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.delegate?.handleHashtagClicker(hashtag: string)
                self.routeToHashtag(hashtag: string)
            } else {
                self.delegate?.showPopUp()
            }
        }
        
        cell.updateFeed = { [weak self] feed in
            guard let self = self else { return }
            self.basePresenter.currentMultipleIndex[row] = cell.selebCarouselView.pageController.currentPage
            self.basePresenter.likeFeedRemote(feed: feed, index: row)
        }
        
        cell.commentHandler = { [weak self] item in
            guard let self = self else { return }
            self.delegate?.handleCommentClicked(feed: item, row: row)
        }
        
        cell.likeHandler = { [weak self] item in
            guard let self = self else { return }
            self.delegate?.handleLikeFeedClicked(feed: item, row: row)
        }
        
        cell.reportHandler = { [weak self] id, accountId, imageURL in
            guard let self = self else { return }
            self.handleReport(id, accountId, imageURL, row)
        }
        cell.sharedHandler = {[weak self] in
            guard let self = self else { return }
            self.delegate?.handleShareFeedClicked(feed: data)
        }
        
        cell.seeProductHandler = {[weak self] in
            guard let self = self else { return }
            if AUTH.isLogin() {
                var product = data.post?.product
                product?.medias = data.post?.product?.medias
                product?.sellerName = data.post?.product?.sellerName
                self.routeToProductDetail(product: product!, index: row)
            } else {
                self.delegate?.showPopUp()
            }
        }
        
        cell.wikipediaHandler = { [weak self] url in
            guard let self = self else { return }
            self.routeToBrowser(url: url)
        }
        
        cell.shopHandler = { [weak self] id in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.routeToShop(id: id)
            } else {
                self.delegate?.showPopUp()
            }
        }
        
        cell.dmHandler = { [weak self] id in
            guard let self = self else { return }
            if AUTH.isLogin() {
                self.routeToDM(account: id)
            } else {
                self.delegate?.showPopUp()
            }
        }
        cell.delegate = self
        cell.setup(feed: data, expanded: self.checkExpandedRow(row), height: self.getCachedHeight(indexPath: row, id: data.id ?? ""))
        return cell
    }
    
    private func setupObserveable() {
        self.mainView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        basePresenter.loadingState.asObservable().map{!$0}.bind(to: mainView.footerView.rx.isHidden).disposed(by: disposeBag)
        
        basePresenter.loadingState.asObservable().subscribe { bool in
            if (!bool){
                self.mainView.refreshController.endRefreshing()
            }
        } onError: { err in
            print(err)
        }.disposed(by: disposeBag)
        
        mainView.tableView.rx.didEndDisplayingCell.bind { [weak self] cell, index in
            guard self != nil else { return }
            print("%%% didEndDisplayingCell \(index.row)")

            if let cell = cell as? BaseFeedTableViewCell2  {
                cell.stopVideo()
                cell.stopTimer()
            }
            
            if let cell = cell as? BaseFeedMultipleTableViewCell  {
                cell.selebCarouselView.pauseAll()
                cell.stopTimer()
            }
        }.disposed(by: disposeBag)
        
        basePresenter.feedsDataSource.bind { [weak self] feed in
            guard let self = self else { return }
            if self.bindCell {
                self.mainView.tableView.reloadData()
            } else {
                self.bindCell = true
            }
        }.disposed(by: disposeBag)
        
        mainView.tableView.rx.willDisplayCell.bind { [weak self] cell, index in
            guard let self = self else { return }
            
            print("%%% willDisplayCell \(index.row)")
            if let cell = cell as? BaseFeedTableViewCell2  {
                cell.row = index.row
                let data = self.basePresenter.feedsDataSource.value
                if data[index.row].id == data[0].id {
                    self.handlePlayingVideoByCellVisibility("will display")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.handlePlayingVideoByCellVisibility("will display")
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.handlePlayingVideoByCellVisibility("will display")
                    }
                }
            } else {
                self.handlePlayingVideoByCellVisibility("will display")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.handlePlayingVideoByCellVisibility("will display")
                }
            }
            
            
        }.disposed(by: disposeBag)
        

    }
    
    func routeToHashtag(hashtag: String){
//        let hashtagVC = HashtagListViewController()
//        hashtagVC.hashtag = hashtag
//        hashtagVC.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(hashtagVC, animated: true)
    }
    
    func routeToProductDetail(product: Product, index: Int){
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: product)
        detailController.hidesBottomBarWhenPushed = true
        UserDefaults.standard.set(index, forKey: indexProductDetailFromFeed)
        UserDefaults.standard.set(true, forKey: productDetailFromFeed)
       self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    func routeToBrowser(url: String) {
        let browserController = AlternativeBrowserController(url: url)
        browserController.bindNavigationBar("", false)
        
        let navigate = UINavigationController(rootViewController: browserController)
        navigate.modalPresentationStyle = .fullScreen
        
        self.present(navigate, animated: false, completion: nil)
    }
    
    func routeToShop(id: String) {
        if id == getIdUser() {
            let storeController = MyProductFactory.createMyProductController()
            storeController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(storeController, animated: false)
        } else {
            var profile = Profile.emptyObject()
            profile.id = id
            let storeController = AnotherProductFactory.createAnotherProductController(account: profile)
            storeController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(storeController, animated: false)
        }
    }
    
    func routeToDM(account: Profile) {
        
    }
    
    func onNavigateToChannel(channelUrl: String) {
        
    }
    
    func routeToFakeDM(account: Profile) {
        
    }
    
    func leaveFakeDM(account: Profile) {
        
    }
    
    func routeToComment(_ id: String, _ item: Feed, updateLike : @escaping (Bool, Int) -> (), updateComment : @escaping (Int) -> (), isDeleted : @escaping () -> ()) {

        let comment = CommentDataSource(id: id)
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
    }
}

extension BaseFeedViewController: CellDelegate {
    func zooming(started: Bool) {
        self.zoomDelegate?.zoom(started: started)
        self.mainView.tableView.isScrollEnabled = !started
    }
}

extension BaseFeedViewController: MultipleFeedCell {
    func updateIndex(index: Int) {
        self.indexToScroll = index
    }
}

