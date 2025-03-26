//
//  MediaItemViewModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 13/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class MediaItemViewModel : ListDiffable {

	let thumbnail : String
	let url : String
	var isVideo : Bool
	
	init(thumbnail: String, url: String, isVideo: Bool) {
		self.thumbnail = thumbnail
		self.url = url
		self.isVideo = isVideo
	}
	
	func diffIdentifier() -> NSObjectProtocol {
		return url as NSObjectProtocol
	}
	
	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard let object = object as? MediaItemViewModel else { return false }
		return url == object.url
	}
}
