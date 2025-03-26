//
//  StoryPreviewView.swift
//  RnDPersada
//
//  Created by NOOR on 13/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import UIKit

class StoryPreviewView: UIView {
	
	//MARK:- iVars
	var layoutType: layoutType?
	/**Layout Animate options(ie.choose which kinda animation you want!)*/
	lazy var layoutAnimator: (LayoutAttributesAnimator, Bool, Int, Int) = (layoutType!.animator, true, 1, 1)
	lazy var snapsCollectionViewFlowLayout: AnimatedCollectionViewLayout = {
		let flowLayout = AnimatedCollectionViewLayout()
		flowLayout.scrollDirection = .horizontal
		flowLayout.animator = layoutAnimator.0
		flowLayout.minimumLineSpacing = 0.0
		flowLayout.minimumInteritemSpacing = 0.0
		return flowLayout
	}()
	
	lazy var snapsCollectionView: UICollectionView! = {
		let cv = UICollectionView.init(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height:  UIScreen.main.bounds.height), collectionViewLayout: snapsCollectionViewFlowLayout)
		cv.backgroundColor = .black
		cv.showsVerticalScrollIndicator = false
		cv.showsHorizontalScrollIndicator = false
		cv.registerCustomCell(StoryPreviewCell.self)
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.isPagingEnabled = true
		return cv
	}()
	
	//MARK:- Overridden functions
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	convenience init(layoutType: layoutType) {
		self.init()
		self.layoutType = layoutType
		createUIElements()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	//MARK: - Private functions
	private func createUIElements(){
		addSubview(snapsCollectionView)
//		snapsCollectionView.fillSuperviewSafeAreaLayoutGuide()
	}
}
