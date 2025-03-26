//
//  NewsCellViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class NewsCellViewModel: Hashable, Equatable {
    
    static func == (lhs: NewsCellViewModel, rhs: NewsCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    let identifier: UUID = UUID()
    var imageList : [String] = []
    let imageNewsUrl: String?
    let source: String?
    let title: String?
    var likes: Int?
    let link: String?
    var comment: Int?
    let postId: String?
    let accountId: String?
    let id: String?
    let published: Int?
    var isLike: Bool?
    var newsDetail: NewsDetail?
    
    init?(value: NewsDetail?) {
        
        guard let source: String = value?.postNews?.siteReference,
              let title: String = value?.postNews?.title,
              let likes: Int = value?.likes,
              let link: String = value?.postNews?.siteReference,
              let comment: Int = value?.comments,
              let id: String = value?.id,
              let postId: String = value?.postNews?.id,
              let accountId: String = value?.account?.id,
              let isLike: Bool = value?.isLike,
              let published: Int = value?.createAt else {
                  return nil
              }
        
        if let media = value?.postNews?.medias {
            if media.first?.thumbnail?.medium == nil {
                imageNewsUrl = media.first?.thumbnail?.large
            } else {
                imageNewsUrl = media.first?.thumbnail?.medium
            }
        } else {
            if let thumb = value?.postNews?.thumbnailUrl {
                imageNewsUrl = thumb
            } else {
                imageNewsUrl = ""
            }
        }
        
        self.id = id
        self.postId = postId
        self.accountId = accountId
        self.title = title
        self.likes = likes
        self.link = link
        self.comment = comment
        self.published = published
        self.source = source
        self.isLike = isLike
        self.newsDetail = value
        
        let matched = matches(for: "(http[^\\s]+(jpg|jpeg|png|tiff)\\b)", in: String(value?.postNews?.content ?? ""))
        
        print("matched \(matched)")
        self.imageList = matched
    }
    
    func matches(for regex: String!, in text: String!) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
