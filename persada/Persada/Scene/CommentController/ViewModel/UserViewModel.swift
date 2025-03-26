//
//  CommentHeaderViewModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 05/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class UserViewModel : ListDiffable {

	var userPhoto : String
	var userName : String
	var type : String
	var userID : String
    var isHaveShop : Bool
    var isOnWikipedia : Bool
    var wikipediaURL : String
    var isVerified : Bool
    var account : Profile
	
    internal init(userPhoto: String, userName: String, type : String, userID : String, isHaveShop : Bool, isOnWikipedia : Bool, wikipediaURL : String, isVerified : Bool, account: Profile) {
		self.userPhoto = userPhoto
		self.userName = userName
		self.type = type
		self.userID = userID
        self.isHaveShop = isHaveShop
        self.isOnWikipedia = isOnWikipedia
        self.wikipediaURL = wikipediaURL
        self.isVerified = isVerified
        self.account = account
	}
	
	func diffIdentifier() -> NSObjectProtocol {
		return "user" as NSObjectProtocol
	}
	
	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		if let object = object as? UserViewModel {
				 return userID == object.userID
			 }
			 return false
	}
}


