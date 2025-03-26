//
//  CircularProgressView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 07/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

public class CircularProgressBar: UIView {
    
    //MARK: awakeFromNib
    public override func awakeFromNib() {
        super.awakeFromNib()
        label.text = "0"
        setupView()
    }
    
    public private(set) var lastProgress: Double = 0.0
    
    //MARK: Public
    
    public var successColor: UIColor = .success {
        didSet {
            setForegroundLayerColorForSafePercent()
        }
    }
    
    public var progressColor: UIColor = .primary {
        didSet {
            setForegroundLayerColorForSafePercent()
        }
    }
    
    public var lineBackgroundColor: UIColor = .whiteSmoke {
        didSet {
            backgroundLayer.strokeColor = lineBackgroundColor.cgColor
        }
    }
    
    public var lineWidth:CGFloat = 6 {
        didSet {
            foregroundLayer.lineWidth = lineWidth
            backgroundLayer.lineWidth = lineWidth - (0.20 * lineWidth)
        }
    }
    
    public var labelSize: CGFloat = 8 {
        didSet {
            label.font = .roboto(.medium, size: labelSize)
            label.sizeToFit()
            configLabel()
        }
    }
    
    public var safePercent: Int = 100 {
        didSet {
            setForegroundLayerColorForSafePercent()
        }
    }
    
    public func setProgress(to progressConstant: Double, withAnimation: Bool) {
        
        var progress: Double {
            get {
                if progressConstant > 1 { return 1 }
                else if progressConstant < 0 { return 0 }
                else { return progressConstant }
            }
        }
        foregroundLayer.strokeEnd = CGFloat(progress)
        if progress != 1.0 && label.isHidden{
            label.isHidden = false
        }
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = lastProgress
            animation.toValue = progress
            animation.duration = 0.25
            foregroundLayer.add(animation, forKey: "foregroundAnimation")
        }
        lastProgress = progress
        label.text = "\(Int(self.lastProgress * 100))%"
        setForegroundLayerColorForSafePercent()
        configLabel()
        configImage()
    }
    
    //MARK: Private
    public var label = UILabel()
    public var image = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    
    private var radius: CGFloat {
        get{
            if self.frame.width < self.frame.height { return (self.frame.width - lineWidth) / 2 }
            else { return (self.frame.height - lineWidth) / 2 }
        }
    }
    
    private var pathCenter: CGPoint{ get{ return self.convert(self.center, from:self.superview) } }
    
    private func makeBar(){
        self.layer.sublayers = nil
        drawBackgroundLayer()
        drawForegroundLayer()
    }
    
    private func drawBackgroundLayer(){
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        self.backgroundLayer.path = path.cgPath
        self.backgroundLayer.strokeColor = lineBackgroundColor.cgColor
        self.backgroundLayer.lineWidth = lineWidth - (lineWidth * 20 / 100)
        self.backgroundLayer.fillColor = UIColor.white.cgColor
        self.layer.addSublayer(backgroundLayer)
        
    }
    
    private func drawForegroundLayer(){
        
        let startAngle = ( -CGFloat.pi / 2)
        let endAngle = 2 * CGFloat.pi + startAngle
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        foregroundLayer.lineCap = CAShapeLayerLineCap.square
        foregroundLayer.path = path.cgPath
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeColor = progressColor.cgColor
        foregroundLayer.strokeEnd = 0

        self.layer.addSublayer(foregroundLayer)
        
    }
    
    private func makeLabel(withText text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.text = text
        label.font = UIFont.systemFont(ofSize: labelSize)
        label.sizeToFit()
        label.center = pathCenter
        return label
    }

    private func configImage() {
        image.sizeToFit()
        image.image = UIImage(named: AssetEnum.ic_check.rawValue)
        image.center = pathCenter
        image.isHidden = true
    }
    
    private func configLabel(){
        label.sizeToFit()
        label.font = .roboto(.medium, size: labelSize)
        label.textColor = .primary
        label.center = pathCenter
    }
    
    private func setForegroundLayerColorForSafePercent(){
        let text = label.text?.trimmingCharacters(in: ["%"])
        if Int(text ?? "0")! >= self.safePercent {
            DispatchQueue.main.async {
                self.foregroundLayer.strokeColor = self.successColor.cgColor
                self.image.isHidden = false
                self.label.isHidden = true
            }
        } else {
            self.foregroundLayer.strokeColor = progressColor.cgColor
        }
    }
    
    public func setRetryView() {
        setProgress(to: 0, withAnimation: false)
        image.image = UIImage(named: AssetEnum.ic_refresh.rawValue)
        self.image.isHidden = false
        self.label.isHidden = true
    }
    
    private func setupView() {
        makeBar()
        self.backgroundColor = .clear
        self.addSubview(label)
        self.addSubview(image)
        configImage()
    }
    
    
    
    //Layout Sublayers
    private var layoutDone = false
    public override func layoutSublayers(of layer: CALayer) {
        if !layoutDone {
            let tempText = label.text
            setupView()
            label.text = tempText
            layoutDone = true
        }
    }
    
}
