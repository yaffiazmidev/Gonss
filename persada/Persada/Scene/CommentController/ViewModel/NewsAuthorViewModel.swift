//
//  NewsHeaderViewModel.swift
//  KipasKipas
//
//  Created by koanba on 17/09/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class NewsAuthorViewModel : ListDiffable {

    let editor : String
    let author : String
    
    internal init(editor: String, author: String) {
        self.editor = editor
        self.author = author
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "newsAuthor" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NewsAuthorViewModel else { return false }
        return author == object.author
    }

}
