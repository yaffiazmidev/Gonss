//
//  TwicketSegmentedControl.swift
//  TwicketSegmentedControlDemo
//
//  Created by Pol Quintana on 7/11/15.
//  Copyright © 2015 Pol Quintana. All rights reserved.
//

import UIKit

public protocol TwicketSegmentedControlDelegate: AnyObject {
	func didSelect(_ segmentIndex: Int)
}

open class TwicketSegmentedControl: UIControl {
	public static let height: CGFloat = Constants.height + Constants.topBottomMargin * 2
	
	private struct Constants {
		static let height: CGFloat = 30
		static let topBottomMargin: CGFloat = 5
		static let leadingTrailingMargin: CGFloat = 10
	}
	
	class SliderView: UIView {
		// MARK: - Properties
		fileprivate let sliderMaskView = UIView()
        fileprivate let lineMaskView = UIView()
		
		var cornerRadius: CGFloat! {
			didSet {
				layer.cornerRadius = cornerRadius
				sliderMaskView.layer.cornerRadius = cornerRadius
			}
		}
		
		override var frame: CGRect {
			didSet {
                sliderMaskView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height:frame.height - 3)
                lineMaskView.frame = CGRect(x: frame.origin.x + 20, y: 27, width: frame.width * 0.3, height: 6)
			}
		}
		
		override var center: CGPoint {
			didSet {
                sliderMaskView.center.x = center.x
                lineMaskView.center.x = center.x
			}
		}
		
		init() {
			super.init(frame: .zero)
			setup()
		}
		
		required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
			setup()
		}
		
		private func setup() {
			layer.masksToBounds = true
			sliderMaskView.backgroundColor = .black
			sliderMaskView.addShadow(with: .black)
            
            lineMaskView.backgroundColor = .black
            lineMaskView.addShadow(with: .black)
		}
	}
	
	open weak var delegate: TwicketSegmentedControlDelegate?
	
	open var defaultTextColor: UIColor = Palette.defaultTextColor {
		didSet {
			updateLabelsColor(with: defaultTextColor, selected: false)
		}
	}
	
	open var highlightTextColor: UIColor = Palette.highlightTextColor {
		didSet {
			updateLabelsColor(with: highlightTextColor, selected: true)
		}
	}
	
	open var segmentsBackgroundColor: UIColor = Palette.segmentedControlBackgroundColor {
		didSet {
			backgroundView.backgroundColor = segmentsBackgroundColor
		}
	}
	
	open var sliderBackgroundColor: UIColor = Palette.sliderColor {
		didSet {
			selectedContainerView.backgroundColor = sliderBackgroundColor
			if !isSliderShadowHidden { selectedContainerView.addShadow(with: sliderBackgroundColor) }
		}
	}
	
	open var font: UIFont = .Roboto(.bold, size: 15) {
		didSet {
			updateLabelsFont(with: font)
		}
	}
	
	open var isSliderShadowHidden: Bool = false {
		didSet {
			updateShadow(with: sliderBackgroundColor, hidden: isSliderShadowHidden)
		}
	}
    
    //made cornerRadius public
    open var cornerRadius: CGFloat = .greatestFiniteMagnitude {
            didSet {
                let cr = cornerRadius == .greatestFiniteMagnitude ? backgroundView.frame.height / 2 : cornerRadius
                [backgroundView, selectedContainerView].forEach { $0.layer.cornerRadius = cr }
                sliderView.cornerRadius = cr
            }
        }

	
	private(set) open var selectedSegmentIndex: Int = 0
	
    var segments: [String] = []
	
	private var numberOfSegments: Int {
		return segments.count
	}
	
	private var segmentWidth: CGFloat {
		return self.backgroundView.frame.width / CGFloat(numberOfSegments)
	}
	
	private var correction: CGFloat = 0
	
	private lazy var containerView: UIView = UIView()
	private lazy var backgroundView: UIView = UIView()
	private lazy var selectedContainerView: UIView = UIView()
    private lazy var selectedLineView: UIView = UIView();
	private lazy var sliderView: SliderView = SliderView()
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	// MARK: Setup
	
	private func setup() {
		addSubview(containerView)
		containerView.addSubview(backgroundView)
		containerView.addSubview(selectedContainerView)
		containerView.addSubview(sliderView)
		
        let maskLayer = CALayer()
        maskLayer.frame = selectedContainerView.bounds
        maskLayer.addSublayer(sliderView.sliderMaskView.layer)
        maskLayer.addSublayer(sliderView.lineMaskView.layer)
           
        selectedContainerView.layer.mask = maskLayer
		addTapGesture()
		addDragGesture()
	}
	
	open func setSegmentItems(_ segments: [String]) {
		guard !segments.isEmpty else { fatalError("Segments array cannot be empty") }
		
		self.segments = segments
		configureViews()
		
		clearLabels()
		
		for (index, title) in segments.enumerated() {
			let baseLabel = createLabel(with: title, at: index, selected: false)
			let selectedLabel = createLabel(with: title, at: index, selected: true)
            
			backgroundView.addSubview(baseLabel)
			selectedContainerView.addSubview(selectedLabel)
            selectedContainerView.addSubview(selectedLineView)
		}
		
		setupAutoresizingMasks()
	}
    
    open func updateConfigureViews(color: UIColor) {
        selectedLineView.backgroundColor = color
    }
	
	private func configureViews() {
		containerView.frame = CGRect(
			x: Constants.leadingTrailingMargin,
			y: Constants.topBottomMargin,
			width: bounds.width - Constants.leadingTrailingMargin * 2,
			height: Constants.height)

		let frame = containerView.bounds
		backgroundView.frame = frame
        selectedContainerView.frame = frame
        selectedLineView.frame = CGRect(
            x: Constants.leadingTrailingMargin + 12,
            y: 27,
            width: bounds.width - Constants.leadingTrailingMargin * 2,
            height: 2)
		sliderView.frame = CGRect(x: 0, y: 0, width: segmentWidth, height: backgroundView.frame.height)
		
        let cr = cornerRadius == .greatestFiniteMagnitude ? backgroundView.frame.height / 2 : cornerRadius
                [backgroundView, selectedContainerView].forEach { $0.layer.cornerRadius = cr }
                sliderView.cornerRadius = cr
		
		backgroundColor = .white
		backgroundView.backgroundColor = segmentsBackgroundColor
		selectedContainerView.backgroundColor = sliderBackgroundColor
        selectedLineView.backgroundColor = .gradientStoryOne
		
		if !isSliderShadowHidden {
			selectedContainerView.addShadow(with: sliderBackgroundColor)
            selectedLineView.addShadow(with: sliderBackgroundColor)
		}
	}
	
	private func setupAutoresizingMasks() {
		containerView.autoresizingMask = [.flexibleWidth]
		backgroundView.autoresizingMask = [.flexibleWidth]
		selectedContainerView.autoresizingMask = [.flexibleWidth]
        selectedLineView.autoresizingMask = [.flexibleWidth]
		sliderView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
	}
	
	private func updateShadow(with color: UIColor, hidden: Bool) {
		if hidden {
			selectedContainerView.removeShadow()
            selectedLineView.removeShadow()
			sliderView.sliderMaskView.removeShadow()
            sliderView.lineMaskView.removeShadow()
		} else {
			selectedContainerView.addShadow(with: sliderBackgroundColor)
            selectedLineView.addShadow(with: sliderBackgroundColor)
			sliderView.sliderMaskView.addShadow(with: .black)
            sliderView.lineMaskView.addShadow(with: .black)
		}
	}
	
	// MARK: Labels
	
	private func clearLabels() {
		backgroundView.subviews.forEach { $0.removeFromSuperview() }
		selectedContainerView.subviews.forEach { $0.removeFromSuperview() }
	}
	
	private func createLabel(with text: String, at index: Int, selected: Bool) -> UILabel {
		let rect = CGRect(x: CGFloat(index) * segmentWidth, y: 0, width: segmentWidth, height: backgroundView.frame.height)
		let label = UILabel(frame: rect)
		label.text = text
		label.textAlignment = .center
		label.textColor = selected ? highlightTextColor : defaultTextColor
		label.font = font
		label.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]

		return label
	}
	
	private func updateLabelsColor(with color: UIColor, selected: Bool) {
		let containerView = selected ? selectedContainerView : backgroundView
		containerView.subviews.forEach { ($0 as? UILabel)?.textColor = color }
	}
	
	private func updateLabelsFont(with font: UIFont) {
		selectedContainerView.subviews.forEach { ($0 as? UILabel)?.font = font }
		backgroundView.subviews.forEach { ($0 as? UILabel)?.font = font }
	}
    
    func updateLabelsFont(selectedFont: UIFont, backgroundFont: UIFont) {
        selectedContainerView.subviews.forEach { ($0 as? UILabel)?.font = selectedFont }
        backgroundView.subviews.forEach { ($0 as? UILabel)?.font = backgroundFont }
    }
	
	// MARK: Tap gestures
	
	private func addTapGesture() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
		addGestureRecognizer(tap)
	}
	
	private func addDragGesture() {
		let drag = UIPanGestureRecognizer(target: self, action: #selector(didPan))
		sliderView.addGestureRecognizer(drag)
	}
	
	@objc private func didTap(tapGesture: UITapGestureRecognizer) {
		moveToNearestPoint(basedOn: tapGesture)
	}
	
	@objc private func didPan(panGesture: UIPanGestureRecognizer) {
		switch panGesture.state {
		case .cancelled, .ended, .failed:
			moveToNearestPoint(basedOn: panGesture, velocity: panGesture.velocity(in: sliderView))
		case .began:
			correction = panGesture.location(in: sliderView).x - sliderView.frame.width/2
		case .changed:
			let location = panGesture.location(in: self)
			sliderView.center.x = location.x - correction
		case .possible: ()
		}
	}
	
	// MARK: Slider position
	
	private func moveToNearestPoint(basedOn gesture: UIGestureRecognizer, velocity: CGPoint? = nil) {
		var location = gesture.location(in: self)
		if let velocity = velocity {
			let offset = velocity.x / 12
			location.x += offset
		}
		let index = segmentIndex(for: location)
		move(to: index)
		delegate?.didSelect(index)
	}
	
	open func move(to index: Int) {
		let correctOffset = center(at: index)
		animate(to: correctOffset)
		
		selectedSegmentIndex = index
	}
	
	private func segmentIndex(for point: CGPoint) -> Int {
		var index = Int(point.x / sliderView.frame.width)
		if index < 0 { index = 0 }
		if index > numberOfSegments - 1 { index = numberOfSegments - 1 }
		return index
	}
	
	private func center(at index: Int) -> CGFloat {
		let xOffset = CGFloat(index) * sliderView.frame.width + sliderView.frame.width / 2
		return xOffset
	}
	
	private func animate(to position: CGFloat) {
		UIView.animate(withDuration: 0.2) {
			self.sliderView.center.x = position
		}
	}
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.sliderView.center.x = center(at: 0)
    }
}
