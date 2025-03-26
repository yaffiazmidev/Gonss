//
//  CaptionViewModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 05/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class CaptionViewModel : ListDiffable {

	let userName : String
	let caption : String
	let date : String
	
	init(userName: String, caption: String, date : String) {
		self.userName = userName
		self.caption = caption
		self.date = date
	}
	
	func diffIdentifier() -> NSObjectProtocol {
		return "caption" as NSObjectProtocol
	}
	
	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard let object = object as? CaptionViewModel else { return false }
		return caption == object.caption
	}

}
