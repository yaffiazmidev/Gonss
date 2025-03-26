//
//  TiktokFollowingCleepsCell.swift
//  FeedCleeps
//
//  Created by DENAZMI on 30/11/22.
//

import UIKit
import KipasKipasShared

class TiktokFollowingCleepsCell: UICollectionViewCell {

    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var closeAllSuggestView: UIView!
    var users: [FollowingSuggestionContent] = [] {
        didSet {
            if self.pagerView != nil {
                self.closeAllSuggestView.isHidden = !users.isEmpty
                self.pagerView.reloadData()
            }
        }
    }
        
    var handleTapUserProfile: ((String) -> Void)?
    var handleFollowButton: ((String, Bool) -> Void)?
    var handleReloadWhenUsersEmpty: (() -> Void)?
    var handleLoadmore: (() -> Void)?
    var handleShowSuggest: (() -> Void)?
    var handleTapUserPostImage: ((String, Feed?) -> Void)?
    
    @IBOutlet weak var showSuggestButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPagerView()
        
        let onTapShowSuggestGesture = UITapGestureRecognizer(target: self, action: #selector(didTapShowSuggestButton))
        showSuggestButton.isUserInteractionEnabled = true
        showSuggestButton.addGestureRecognizer(onTapShowSuggestGesture)
    }
    
    private func setupPagerView() {
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.interitemSpacing = 12.5
        pagerView.removesInfiniteLoopForSingleItem = true
        let transformer = FSPagerViewTransformer(type: .linear)
        transformer.minimumScale = 0.90
        pagerView.transformer = transformer
        pagerView.itemSize = CGSize(width: 234, height: 350)
        pagerView.register(UINib(nibName: "CarouselFollowingCleepsCell", bundle: SharedBundle.shared.bundle), forCellWithReuseIdentifier: "CarouselFollowingCleepsCell")
    }
    
    @objc func didTapShowSuggestButton() {
        handleShowSuggest?()
    }
}

extension TiktokFollowingCleepsCell: FSPagerViewDataSource {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return users.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "CarouselFollowingCleepsCell", at: index) as! CarouselFollowingCleepsCell
        cell.user = users[index]
        cell.handleClickCloseButton = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.users.remove(at: index)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pagerView.reloadData()
                cell.closeIconStackView.isUserInteractionEnabled = true
                self.closeAllSuggestView.isHidden = !self.users.isEmpty
            }
        }
        
        cell.handleClickFollowButton = { [weak self] in
            guard let self = self else { return }
            self.pagerView.reloadData()
            self.handleFollowButton?(self.users[index].account?.id ?? "", self.users[index].account?.isFollow ?? false)
        }
        
        cell.handleTapUserProfile = { [weak self] in
            guard let self = self else { return }
            self.handleTapUserProfile?(self.users[index].account?.id ?? "")
        }
        
        cell.handleTapUserPostImage = { [weak self] feedId in
            guard let self = self else { return }
            
            guard let feedIndex = self.users[index].feeds?.firstIndex(where: { $0.id == feedId }) else { return }
            
            self.handleTapUserPostImage?(self.users[index].account?.id ?? "", self.users[index].feeds?[feedIndex])
        }
        
        return cell
    }
}


extension TiktokFollowingCleepsCell: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        loadMore()
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        loadMore()
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        loadMore()
    }
    
    func loadMore() {
        if pagerView.currentIndex == users.count - 1 {
            handleLoadmore?()
        }
    }
}

//extension TiktokFollowingCleepsCell {
//    func dummyUser() -> [FollowingSuggestionContent] {
//        return [
//            FollowingSuggestionContent(
//                account: FollowingSuggestionAccount(
//                    id: "2c9481b478592ee401785d8500d7007f",
//                    username: "yayufrhyy",
//                    name: "iyayyyyyyyyuyeeeuyaaahdjdjdjdjdjdjjdjdiyaaaayyyyyy",
//                    photo: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/account/1660630052968.jpg",
//                    isFollow: false),
//                feeds: [
//                    FollowingSuggestionFeed(post: FollowingSuggestionPost(
//                        id: "402880e784bcef980184bd13c3ce0069", medias: [
//                            FollowingSuggestionMedia(id: "402880e784bcef980184bd13c3e4006b", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1669619498075.jpg")
//                        ])
//                    ),
//                    FollowingSuggestionFeed(post: FollowingSuggestionPost(
//                        id: "402880e784bcef980184bd13c3ce0069", medias: [
//                            FollowingSuggestionMedia(id: "402880e784bcef980184bd13c3e4006b", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1669619498075.jpg")
//                        ])
//                    ),
//                    FollowingSuggestionFeed(post: FollowingSuggestionPost(
//                        id: "402880e784bcef980184bd13c3ce0069", medias: [
//                            FollowingSuggestionMedia(id: "402880e784bcef980184bd13c3e4006b", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1669619498075.jpg")
//                        ])
//                    )
//                ]
//            ),
//            FollowingSuggestionContent(
//                account: FollowingSuggestionAccount(
//                    id: "2c9481b478592ee401785d8500d7007f",
//                    username: "denazmi",
//                    name: "DENAZMI",
//                    photo: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/account/1660630052968.jpg",
//                    isFollow: false),
//                feeds: [
//                    FollowingSuggestionFeed(post: FollowingSuggestionPost(
//                        id: "402880e784bcef980184bd13c3ce0069", medias: [
//                            FollowingSuggestionMedia(id: "402880e784bcef980184bd13c3e4006b", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1669619498075.jpg")
//                        ])
//                    ),
//                    FollowingSuggestionFeed(post: FollowingSuggestionPost(
//                        id: "402880e784bcef980184bd13c3ce0069", medias: [
//                            FollowingSuggestionMedia(id: "402880e784bcef980184bd13c3e4006b", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1669619498075.jpg")
//                        ])
//                    ),
//                    FollowingSuggestionFeed(post: FollowingSuggestionPost(
//                        id: "402880e784bcef980184bd13c3ce0069", medias: [
//                            FollowingSuggestionMedia(id: "402880e784bcef980184bd13c3e4006b", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1669619498075.jpg")
//                        ])
//                    )
//                ]
//            ),
//            FollowingSuggestionContent(
//                account: FollowingSuggestionAccount(
//                    id: "2c9481b478592ee401785d8500d7007f",
//                    username: "naruto",
//                    name: "Naruto Uzumaki",
//                    photo: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/account/1660630052968.jpg",
//                    isFollow: false),
//                feeds: [
//                    FollowingSuggestionFeed(post: FollowingSuggestionPost(
//                        id: "402880e784bcef980184bd13c3ce0069", medias: [
//                            FollowingSuggestionMedia(id: "402880e784bcef980184bd13c3e4006b", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1669619498075.jpg")
//                        ])
//                    ),
//                    FollowingSuggestionFeed(post: FollowingSuggestionPost(
//                        id: "402880e784bcef980184bd13c3ce0069", medias: [
//                            FollowingSuggestionMedia(id: "402880e784bcef980184bd13c3e4006b", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1669619498075.jpg")
//                        ])
//                    ),
//                    FollowingSuggestionFeed(post: FollowingSuggestionPost(
//                        id: "402880e784bcef980184bd13c3ce0069", medias: [
//                            FollowingSuggestionMedia(id: "402880e784bcef980184bd13c3e4006b", url: "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1669619498075.jpg")
//                        ])
//                    )
//                ]
//            )
//        ]
//    }
//}
