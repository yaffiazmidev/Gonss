//
//  EmptyCommentCell.swift
//  KipasKipas
//
//  Created by koanba on 19/08/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import IGListKit

class EmptyCommentViewModel: ListDiffable {
    
    var isEmpty: Bool
    
    init(isEmpty: Bool) {
        self.isEmpty = isEmpty
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "emptyComment" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
    
    
}

class EmptyCommentCell: UICollectionViewCell, ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
