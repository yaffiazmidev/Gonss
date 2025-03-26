//
//  NewsHeaderViewModel.swift
//  KipasKipas
//
//  Created by koanba on 17/09/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class NewsHeaderViewModel : ListDiffable {

    let title : String
    let date : String
    let source : String
    let mediaURL : String
    let type : String
    let thumbnail : String
    
    init(title: String, date: String, source: String, mediaURL: String, type: String, thumbnail: String) {
        self.title = title
        self.date = date
        self.source = source
        self.mediaURL = mediaURL
        self.type = type
        self.thumbnail = thumbnail
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "newsHeader" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NewsHeaderViewModel else { return false }
        return title == object.title
    }

}
