//
//  CommentSectionController.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 07/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

protocol MediaProtocol {
    func mediaDidEndDecelerating()
}

final class CommentSectionController : ListBindingSectionController<PostViewModel>, ListBindingSectionControllerDataSource {
    
    var mediaDelegate: MediaProtocol!
    var data = [ListDiffable]()
    var interactor = CommentSectionInteractor()
	let popupReport = ReportPopupViewController(mainView: ReportPopupView())
    private var commentRouter : CommentSectionRouter?
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController, workingRangeSize: 2)
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        
        return adapter
    }()
    
    override init() {
        super.init()
        dataSource = self
        commentRouter = CommentSectionRouter(viewController)
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object  = object as? PostViewModel else { fatalError() }
        let result : [ListDiffable] = [
            object.user,
            object.media,
            object.action,
            object.caption,
            object.emptyComment
        ]
        data.append(contentsOf: object.media.media)
        return result + object.comments.sorted(by: { $0.createAt < $1.createAt })
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        switch viewModel {
        case is UserViewModel:
            let cell = collectionContext?.dequeueReusableCell(withNibName: "UserCell", bundle: nil, for: self, at: index) as! UserCell
            cell.delegate = self
            return cell
        case is MediaViewModel:
            let cell = collectionContext?.dequeueReusableCell(withNibName: "MediaCell", bundle: nil, for: self, at: index) as! MediaCell
            adapter.collectionView = cell.mediaCollectionView
            cell.controller =  self
            cell.delegate = self
            cell.setDelegate()
            return cell
        case is LikeAndCommentViewModel:
            let cell = collectionContext?.dequeueReusableCell(withNibName: "LikeCommentShareCell", bundle: nil, for: self, at: index) as! LikeCommentShareCell
            cell.delegate = self
            return cell
        case is CaptionViewModel:
            let cell = collectionContext?.dequeueReusableCell(withNibName: "CaptionCell", bundle: nil, for: self, at: index) as! CaptionCell
            cell.delegate = self
            return cell
        case is EmptyCommentViewModel:
            let cell = collectionContext?.dequeueReusableCell(withNibName: "EmptyCommentCell", bundle: nil, for: self, at: index) as! EmptyCommentCell
            return cell
        case is CommentViewModel:
            let cell = collectionContext?.dequeueReusableCell(withNibName: "CommentSectionCell", bundle: nil, for: self, at: index) as! CommentSectionCell
            cell.delegate = self
            return cell
        default:
            return collectionContext?.dequeueReusableCell(withNibName: "CommentSectionCell", bundle: nil, for: self, at: index) as! CommentSectionCell
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        guard let object  = object else { fatalError() }
        let height: CGFloat
        switch viewModel {
        case is UserViewModel : height = 57.0
        case is MediaViewModel :
            if object.media.media.count == 1 && !object.media.isHaveProduct {
                height = CGFloat(object.media.height)
            } else {
                height = CGFloat(object.media.height)
            }
        case is LikeAndCommentViewModel : height = 46.0
        case is CaptionViewModel :
            var descText = object.caption.caption
            while descText.last == "\n" {
                descText.removeLast()
            }
            let captionHeight = descText.height(withConstrainedWidth: width - calculatePercentage(value: width, percentageVal: 10), font: .Roboto(.regular, size: 14))
            let lines = Int(captionHeight / 16)
            height = CGFloat(lines + 3) * 16.0 + 16
        case is EmptyCommentViewModel:
            height = object.comments.isEmpty ? 48 : 0
        case is CommentViewModel :
            let commentHeight = object.comments[index-5].comment.height(withConstrainedWidth: width - calculatePercentage(value: width, percentageVal: 20), font:  .Roboto(.regular, size: 14))
            height = commentHeight + 45.0 + 18
        default: height = 100.0
        }
        return CGSize(width: width, height: height)
    }
    
    func calculatePercentage(value:CGFloat, percentageVal:CGFloat) -> CGFloat{
        let val = value * percentageVal
        return val / 100.0
    }
}

extension CommentSectionController : ListAdapterDataSource, UIScrollViewDelegate {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return MediaSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mediaDelegate.mediaDidEndDecelerating()
    }
}

extension CommentSectionController : UserCellDelegate {
    func didTapUserPhoto(cell: UserCell) {
        guard let viewModel = cell.viewModel else { return }
        let id = viewModel.userID
        let type = viewModel.type
        commentRouter?.routeToProfile(id, type)
    }
    
    func didTapUserName(cell: UserCell) {
        guard let viewModel = cell.viewModel else { return }
        let id = viewModel.userID
        let type = viewModel.type
        commentRouter?.routeToProfile(id, type)
    }
    
    func didTapSubtitleLabel(cell: UserCell) {
        guard let viewModel = cell.viewModel else { return }
        commentRouter?.routeToBrowser(url: viewModel.wikipediaURL)
    }
    
    func didTapShop(cell: UserCell) {
        guard let viewModel = cell.viewModel else { return }
        commentRouter?.routeToShop(id: viewModel.userID)
    }
    
    func didTapChat(cell: UserCell) {
        guard let account = cell.viewModel?.account else { return }
        routeToDM(account: account)
    }
    func routeToDM(account: Profile) {
        
    }
    
    func onNavigateToChannel(channelUrl: String) {
        
    }
    
    func routeToFakeDM(account: Profile) {
        
    }
    
    func leaveFakeDM(account: Profile) {
        
    }
    
    func didTapKebabButton(cell: UserCell) {
        guard let viewModel = cell.viewModel else { return }
        guard let object  = object else { fatalError() }
        if viewModel.userID == getIdUser() {
            viewController?.present(deleteFeedSheet(feedID: object.postID), animated: true, completion: nil)
            return
        }
        guard let url = object.media.media.first?.url else { return }
        viewController?.present(reportFeedSheet(feedID: object.postID, accountID: viewModel.userID, imageURL: url), animated: true, completion: nil)
    }
    
    func reportFeedSheet(feedID: String, accountID: String, imageURL: String) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: .get(.report), style: .default , handler:{ _ in
            self.interactor.report(id: feedID) {
                self.showAlert(title: .get(.report), message: .get(.accountReported))
            } onReportNotExist: {
                self.commentRouter?.presentReportSheet(id: feedID, accountId: accountID, imageUrl: imageURL, reportType: .FEED)
            } onError: { error in
                self.showErrorAlert(error: error)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        return actionSheet
    }
    
    func deleteFeedSheet(feedID: String) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: .get(.deletePost), style: .default , handler:{ _ in
            self.interactor.deleteFeedByID(id: feedID) {
                self.viewController?.navigationController?.popViewController(animated: true)
                guard let vc = self.viewController as? CommentViewController else { fatalError() }
                vc.deleteFeed()
            } onError: { error in
                self.showErrorAlert(error: error)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        return actionSheet
    }
}


extension CommentSectionController : MediaCellDelegate {
    func didTapSeeProduct(cell: MediaCell) {
        guard let viewModel = cell.viewModel else { return }
        guard let productID = viewModel.productID else { return }
        commentRouter?.routeToProductDetail(productID: productID)
    }
}

extension CommentSectionController : CaptionCellDelegate {
    func didTapUsernameCaption(cell: CaptionCell) {
        guard let object  = object else { fatalError() }
        let viewModel = object.user
        commentRouter?.routeToProfile(viewModel.userID, viewModel.type)
    }
    
    func didTapMention(cell: CaptionCell, mention: String) {
        interactor.mention(word: mention) { userID, userType in
            self.commentRouter?.routeToProfile(userID, userType)
        } onError: { error in
            if error == "Data Not Found" {
                self.commentRouter?.routeToEmptyProfile()
            } else {
                self.showErrorAlert(error: error)
            }
        }
    }
    
    func didTapHashtag(cell: CaptionCell, hashtag: String) {
        commentRouter?.routeToHashtag(hashtag: hashtag)
    }
    
    
}

extension CommentSectionController : LikeCommentShareCellDelegate {
    func didTapLike(cell: LikeCommentShareCell) {
        guard let object  = object else { fatalError() }
        let viewModel = object
        let isLike = viewModel.action.isLiked
        
        
        cell.viewModel?.isLiked = !isLike
        guard let vc = self.viewController as? CommentViewController else { fatalError() }
        cell.updateLike(vc: vc)
       
        
        interactor.likeFeed(postId: viewModel.postID, isLike: !isLike) {
        } onError: { error in
            cell.viewModel?.isLiked = isLike
            cell.updateLike(vc: vc)
            self.showErrorAlert(error: error)
        }

    }
    
    func didTapComment(cell: LikeCommentShareCell) {
        
    }
    
    func didTapShare(cell: LikeCommentShareCell) {
        guard let object  = object else { fatalError() }
        let viewModel = object
        let text =  "\(object.user.userName) \n\n\(viewModel.caption.caption) \n\n\nKlik link berikut untuk membuka tautan: \(APIConstants.webURL)/feed/\(viewModel.postID)"
        guard let url = viewModel.media.media.first?.url else { return }
        commentRouter?.shared(text, url: url)
        
    }
    
    
}

extension CommentSectionController : CommentSectionCellDelegate {
    func didTapUserphotoComment(cell: CommentSectionCell) {
        guard let viewModel = cell.viewModel else { return }
        commentRouter?.routeToProfile(viewModel.userID, viewModel.type)
    }
    
    func didTapUsernameComment(cell: CommentSectionCell) {
        guard let viewModel = cell.viewModel else { return }
        commentRouter?.routeToProfile(viewModel.userID, viewModel.type)
    }
    
    func didTapLikeComment(cell: CommentSectionCell) {
        guard let object  = object else { fatalError() }
        let viewModel = object
        
        guard let viewModelCell = cell.viewModel else { fatalError() }
        
        let isLike = viewModelCell.isLike
        
        cell.viewModel?.isLike = !isLike
        cell.updateLike()
        interactor.likeComment(postId: viewModel.postID, commentId: viewModelCell.commentID, isLike: !isLike) {
        } onError: { error in
            cell.viewModel?.isLike = isLike
            cell.updateLike()
            self.showErrorAlert(error: error)
        }
    }
    
    func didTapReportComment(cell: CommentSectionCell) {
        guard let viewModel = cell.viewModel else { return }
        
        
        self.interactor.report(id: viewModel.commentID) {
            self.showAlert(title: .get(.report), message: .get(.accountReported))
        } onReportNotExist: {
            self.commentRouter?.presentReportSheet(id: viewModel.commentID, accountId: viewModel.userID, imageUrl: viewModel.userPhoto, reportType: .COMMENT)
        } onError: { error in
            self.showErrorAlert(error: error)
        }
    }
    
    func didTapReplyComment(cell: CommentSectionCell) {
        guard let object = object else { fatalError() }
        guard let viewModelComment = cell.viewModel else { return }
        let viewModel = object
        
        let dataStore = CommentHeaderCellViewModel(description: viewModelComment.comment, username: viewModelComment.userName, imageUrl: viewModelComment.userPhoto, date: viewModelComment.createAt, feed: nil)
        
        
        commentRouter?.routeToSubComment(userID: viewModelComment.userID, userType: viewModelComment.type, postID: viewModel.postID, commentID: viewModelComment.commentID, dataStore: dataStore, commentAdded: { count in
            cell.viewModel?.totalComment = count
            cell.updateReplyCounter()
        })
    }
    
    func didTapDeleteComment(cell: CommentSectionCell) {
        guard let viewModel = cell.viewModel else { return }
        viewController?.present(deleteCommentSheet(commentID: viewModel.commentID), animated: true, completion: nil)
    }
    
    func didTapMentionComment(cell: CommentSectionCell, mention: String) {
        interactor.mention(word: mention) { userID, userType in
            self.commentRouter?.routeToProfile(userID, userType)
        } onError: { error in
            if error == "Data Not Found" {
                self.commentRouter?.routeToEmptyProfile()
            } else {
                self.showErrorAlert(error: error)
            }
        }
    }
    
    func didTapHashtagComment(cell: CommentSectionCell, hashtag: String) {
        commentRouter?.routeToHashtag(hashtag: hashtag)
    }
    
    
    func deleteCommentSheet(commentID: String) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: .get(.deletePost), style: .default , handler:{ _ in
            self.interactor.deleteComment(id: commentID) {
                guard let object = self.object else { fatalError() }
                let newComments = object.comments.filter({ viewModel in
                    viewModel.commentID != commentID
                })
                object.action.totalComment = object.action.totalComment - 1
                object.comments = newComments
                
                guard let vc = self.viewController as? CommentViewController else { fatalError() }
                vc.refreshCommentCount(post: object)
            } onError: { error in
                self.showErrorAlert(error: error)
            }

        }))
        actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        return actionSheet
    }
}


extension CommentSectionController {
    func showErrorAlert(error: String){
        guard let vc = viewController as? CommentViewController else { fatalError() }
        DispatchQueue.main.async {
            let action = UIAlertAction(title: .get(.ok), style: .default)
            vc.displayAlert(with: .get(.error), message: error, actions: [action])
        }
    }
    
    func showAlert(title: String, message: String){
        guard let vc = viewController as? CommentViewController else { fatalError() }
        DispatchQueue.main.async {
            let action = UIAlertAction(title: .get(.ok), style: .default)
            vc.displayAlert(with: title, message: message, actions: [action])
        }
    }
}
