//
//  MediaSectionController.swift
//  KipasKipas
//
//  Created by PT.Koanba on 13/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class MediaSectionController : ListSectionController {
    
    private var data : MediaItemViewModel?
        
    override init() {
        super.init()
        self.displayDelegate = self
    }
        
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
			
			let cell = collectionContext?.dequeueReusableCell(withNibName: "MediaItemCell", bundle: nil, for: self, at: index) as! MediaItemCell
			if let viewModel = data {
				cell.bindViewModel(viewModel)
			}
			return cell
    }
    
    override func didUpdate(to object: Any) {
			data = object as? MediaItemViewModel
    }
}

extension MediaSectionController : ListDisplayDelegate {
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        print("willDisplay")
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        print("didEndDisplaying")
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        print("willDisplay cell")
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        print("didEndDisplaying cell")
        guard let cell = cell as? MediaItemCell else { return }
        cell.video?.isMuted = true
    }
    
	
}
