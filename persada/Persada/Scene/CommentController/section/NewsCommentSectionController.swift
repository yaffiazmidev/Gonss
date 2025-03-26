//
//  NewsCommentSectionController.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 07/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

final class NewsCommentSectionController : ListBindingSectionController<NewsCommentViewModel>, ListBindingSectionControllerDataSource {
    
    var mediaDelegate: MediaProtocol!
    var data = [ListDiffable]()
    var interactor = CommentSectionInteractor()
    
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
        guard let object  = object as? NewsCommentViewModel else { fatalError() }
        let result : [ListDiffable] = [
            object.newsHeader,
            object.newsAuthor,
            object.emptyComment
        ]
        return result + object.comments
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        switch viewModel {
        case is NewsHeaderViewModel:
            let cell = collectionContext?.dequeueReusableCell(of: NewsHeaderCell.self, for: self, at: index) as! NewsHeaderCell
            return cell
        case is NewsAuthorViewModel:
            let cell = collectionContext?.dequeueReusableCell(of: NewsAuthorCell.self, for: self, at: index) as! NewsAuthorCell
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
        case is NewsHeaderViewModel:
            height = 328
        case is NewsAuthorViewModel:
            height = 90
        case is EmptyCommentViewModel:
            height = object.comments.isEmpty ? 48 : 0
        case is CommentViewModel :
            let commentHeight = object.comments[index-3].comment.height(withConstrainedWidth: width - calculatePercentage(value: width, percentageVal: 20), font:  .Roboto(.regular, size: 12))
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

extension NewsCommentSectionController : ListAdapterDataSource, UIScrollViewDelegate {
    
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

extension NewsCommentSectionController : CommentSectionCellDelegate {
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
                object.comments = newComments
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


extension NewsCommentSectionController {
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
