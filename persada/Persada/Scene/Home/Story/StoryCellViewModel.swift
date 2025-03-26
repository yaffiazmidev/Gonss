//
//  StoryCellViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 12/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct StoryCellViewModel {
	
	let id: String?
	let accountId: String?
	let type: String?
	let imageUserUrl: String?
	let username: String?
	let postStories: [Stories]?
	let account: Profile?
	
	init?(value: Story?) {
		
		guard let id: String = value?.id,
			let accountId: String = value?.account?.id,
			let username: String = value?.account?.username,
			let account: Profile = value?.account else {
				return nil
		}
		
		if value?.stories?.first?.id == nil {
			self.postStories = []
		} else {
			self.postStories = value?.stories
		}

		if value?.account?.photo == "" {
			self.imageUserUrl = ""
		} else {
			self.imageUserUrl = value?.account?.photo
		}
		
		if value?.account?.isSeleb != false {
			self.type = "social"
		} else {
			self.type = "seleb"
		}
		
		self.id = id
		self.accountId = accountId
		self.username = username
		self.account = account
	}
}
