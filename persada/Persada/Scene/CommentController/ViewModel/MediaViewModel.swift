//
//  CommentListViewModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 05/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class MediaViewModel : ListDiffable {

	let media : [MediaItemViewModel]
	let isHaveProduct : Bool
	let productID : String?
	let height : Int
    let price : String
	
    init(media: [MediaItemViewModel], isHaveProduct: Bool, productID: String?, height: Int, price: String) {
		self.media = media
		self.isHaveProduct = isHaveProduct
		self.productID = productID
		self.height = height
        self.price = price
	}

	func diffIdentifier() -> NSObjectProtocol {
		return "media" as NSObjectProtocol
	}
	
	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		return true
	}
}


