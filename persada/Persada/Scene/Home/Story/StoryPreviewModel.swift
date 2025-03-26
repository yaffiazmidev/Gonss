//
//  StoryPreviewModel.swift
//  RnDPersada
//
//  Created by NOOR on 13/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import Foundation

class StoryPreviewModel: NSObject {
		
		//MARK:- iVars
		var stories: [StoriesItem]?
		var handPickedStoryIndex: Int? //starts with(i)
		
		//MARK:- Init method
		init(_ stories: [StoriesItem], _ handPickedStoryIndex: Int) {
				self.stories = stories
				self.handPickedStoryIndex = handPickedStoryIndex
		}
		
		//MARK:- Functions
		func numberOfItemsInSection(_ section: Int) -> Int {
			if let count = stories?.count {
						return count
				}
				return 0
		}
		func cellForItemAtIndexPath(_ indexPath: IndexPath) -> StoriesItem? {
			guard let count = stories?.count else {return nil}
				if indexPath.item < count {
					return stories?[indexPath.item]
				}else {
						fatalError("Stories Index mis-matched :(")
				}
		}
}
