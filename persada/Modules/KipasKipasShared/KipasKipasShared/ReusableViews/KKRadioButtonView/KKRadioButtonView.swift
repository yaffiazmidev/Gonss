//
//  KKRadioButtonView.swift
//  KipasKipasShared
//
//  Created by DENAZMI on 30/05/24.
//

import UIKit

public protocol KKRadioButtonViewDelegate: AnyObject {
    func didUpdate(isActive: Bool)
}

public class KKRadioButtonView: UIView {
    
    private let outerCircleLayer = CAShapeLayer()
    private let innerCircleLayer = CAShapeLayer()
    
    public var isEnable: Bool {
        get { isUserInteractionEnabled }
        set { isUserInteractionEnabled = newValue }
    }
    
    public var isActive: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    public var color: UIColor {
        didSet {
            outerCircleLayer.strokeColor = color.cgColor
            innerCircleLayer.fillColor = color.cgColor
        }
    }
    
    public var activeColor: UIColor {
        didSet {
            outerCircleLayer.strokeColor = activeColor.cgColor
            innerCircleLayer.fillColor = activeColor.cgColor
        }
    }
    
    public var outerCircleLineWidth: CGFloat {
        didSet {
            outerCircleLayer.lineWidth = outerCircleLineWidth
        }
    }
    
    public var innerCirclePadding: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var handleToggleSelection: ((Bool) -> Void)?
    
    // MARK: - Initializers
    
    public init(
        frame: CGRect,
        isActive: Bool,
        color: UIColor = .gray,
        activeColor: UIColor = .black,
        outerCircleLineWidth: CGFloat,
        innerCirclePadding: CGFloat
    ) {
        self.color = color
        self.activeColor = activeColor
        self.outerCircleLineWidth = outerCircleLineWidth
        self.innerCirclePadding = innerCirclePadding
        self.isActive = isActive
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.color = .gray
        self.activeColor = .black
        self.outerCircleLineWidth = 2.0
        self.innerCirclePadding = 4.0
        self.isActive = false
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupLayers()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSelection))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup Methods
    
    private func setupLayers() {
        // Configure outer circle layer
        outerCircleLayer.lineWidth = outerCircleLineWidth
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.strokeColor = color.cgColor
        layer.addSublayer(outerCircleLayer)
        
        // Configure inner circle layer
        innerCircleLayer.fillColor = color.cgColor
        innerCircleLayer.isHidden = !isActive
        layer.addSublayer(innerCircleLayer)
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(bounds.width, bounds.height) / 2
        let outerCirclePath = UIBezierPath(ovalIn: bounds)
        outerCircleLayer.path = outerCirclePath.cgPath
        
        let innerCircleRadius = radius - innerCirclePadding
        let innerCirclePath = UIBezierPath(ovalIn: CGRect(
            x: bounds.midX - innerCircleRadius,
            y: bounds.midY - innerCircleRadius,
            width: innerCircleRadius * 2,
            height: innerCircleRadius * 2))
        innerCircleLayer.path = innerCirclePath.cgPath
    }
    
    // MARK: - Update Appearance
    
    private func updateAppearance() {
        innerCircleLayer.isHidden = !isActive
        outerCircleLayer.strokeColor = isActive ? activeColor.cgColor : color.cgColor
        innerCircleLayer.fillColor = isActive ? activeColor.cgColor : color.cgColor
    }
    
    // MARK: - Actions
    
    @objc private func toggleSelection() {
        isActive.toggle()
        handleToggleSelection?(isActive)
    }
}
