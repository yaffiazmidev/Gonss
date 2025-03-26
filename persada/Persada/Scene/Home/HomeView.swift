//
//  FeedView.swift
//  KipasKipas
//
//  Created by movan on 24/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class HomeView: UIView {
	
	private enum ViewTrait {
		static let padding: CGFloat = 16.0
	}
	
	let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	
	lazy var segmentedControl: TwicketSegmentedControl = {
		let segmented = TwicketSegmentedControl()
		segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.setSegmentItems([String.get(.feed), String.get(.news), String.get(.shop), String.get(.cleeps), .get(.cleepsCN), .get(.cleepsKorea), .get(.cleepsThai)])
        segmented.segmentsBackgroundColor = .clear
        segmented.sliderBackgroundColor = .clear
        segmented.tintColor = .gradientStoryOne
        segmented.defaultTextColor = .contentGrey
		segmented.highlightTextColor = .gradientStoryOne
        segmented.updateLabelsFont(selectedFont: .Roboto(.bold, size: 14), backgroundFont: .Roboto(.medium, size: 14))
		segmented.isSliderShadowHidden = true
        segmented.isHidden = false
        segmented.cornerRadius = 0;
        segmented.backgroundColor = .clear
		return segmented
	}()
    
    lazy var topView: CustomHomeTopView = {
        let view = CustomHomeTopView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		let pageView = pageViewController.view!
        
		pageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(pageView)
		
        pageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: trailingAnchor)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
