//
//  KKFloatingActionButton.swift
//  FeedCleeps
//
//  Created by Muhammad Noor on 10/08/23.
//

import UIKit
import QuartzCore

public enum TitleTextAlignment {
    case left
    case center
    case right
}

public enum TitleLabelPosition {
    case left
    case right
}

public enum CellHorizontalAlign {
    case left
    case center
    case right
    
}

@objc protocol KKFloatingActionButtonDataSource {
    func numberOfCells(_ floatingActionButton: KKFloatingActionButton) -> Int
    func cellForIndex(_ index: Int) -> KKFloatingActionButtonCell
}

@objc protocol KKFloatingActionButtonDelegate {
    @objc optional func floatingActionButton(_ floatingActionButton: KKFloatingActionButton, didSelectItemAtIndex index: Int)
}


class KKFloatingActionButton: UIView {
    public let imageView = UIImageView()  // TODO: private
    var closedImage: UIImage? = nil {
        didSet {
            imageView.image = closedImage
        }
    }
    var openedImage: UIImage? = nil
    private var originalImage: UIImage? = nil
    private var circleLayer: CAShapeLayer = CAShapeLayer()
    
    var shadowOffset: CGSize {
        get { return circleLayer.shadowOffset }
        set { circleLayer.shadowOffset = newValue }
    }
    var shadowOpacity: Float {
        get { return circleLayer.shadowOpacity }
        set { circleLayer.shadowOpacity = newValue }
    }
    var shadowRadius: CGFloat {
        get { return circleLayer.shadowRadius }
        set { circleLayer.shadowRadius = newValue }
    }
    var shadowPath: CGPath? {
        get { return circleLayer.shadowPath }
        set { circleLayer.shadowPath = newValue }
    }
    var shadowColor: UIColor? {
        get {
            guard let color = circleLayer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set { circleLayer.shadowColor = newValue?.cgColor }
    }
    var circlePath: CGPath? {
        return circleLayer.path
    }
    
    var internalRatio: CGFloat = 0.75
    var cellMargin: CGFloat = 10.0
    var btnToCellMargin: CGFloat = 15.0
    
    var size: CGFloat = 50 {
        didSet {
            frame.size = CGSize(width: size, height: size)
            circleLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            circleLayer.cornerRadius = size / 2
            resizeSubviews()
        }
    }
    var color = UIColor(red: 0/255.0, green: 157/255.0, blue: 238/255.0, alpha: 1.0) {
        didSet {
            circleLayer.backgroundColor = color.cgColor
        }
    }
    var touchingColor: UIColor?
    
    var isBackgroundView = false
    private var backgroundView = UIControl()
    var backgroundViewColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5) {
        didSet {
            backgroundView.backgroundColor = backgroundViewColor
        }
    }
    
    var responsible = true
    fileprivate(set) var isClosed = true
    
    var titleLabelPosition = TitleLabelPosition.left  // TODO: move extension
    var cellHorizontalAlign = CellHorizontalAlign.center
    
    weak var delegate:   KKFloatingActionButtonDelegate?
    weak var dataSource: KKFloatingActionButtonDataSource?
    
    private var touching = false
    
    var btnAnimationWithOpen: (KKFloatingActionButton) -> () = { $0.rotate45BtnAnimationWithOpen() }
    var btnAnimationWithClose: (KKFloatingActionButton) -> () = { $0.rotate45BtnAnimationWithClose() }
    var cellAnimationWithOpen: (KKFloatingActionButton) -> () = { $0.popCellAnimationWithOpen() }
    var cellAnimationWothClose: (KKFloatingActionButton) -> () = { $0.popCellAnimationWithClose() }
    
    
    // MARK: - init
    public init(x: CGFloat, y: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: size, height: size))
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    // MARK: -
    override func draw(_ rect: CGRect) {
        responseCircle()
    }
    
    public func cells() -> [KKFloatingActionButtonCell] {
        var result: [KKFloatingActionButtonCell] = []
        guard let source = dataSource else { return result }
        
        for i in 0..<source.numberOfCells(self) {
            result.append(source.cellForIndex(i))
        }
        return result
    }
    
    public func open() {
        if isBackgroundView {
            backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            backgroundView.backgroundColor = backgroundViewColor
            backgroundView.isUserInteractionEnabled = true
            self.superview?.insertSubview(backgroundView, aboveSubview: self)
            self.superview?.bringSubviewToFront(self)
            backgroundView.addTarget(self, action: #selector(close), for: UIControl.Event.touchUpInside)
        }
        if openedImage == nil {
            btnAnimationWithOpen(self)
        } else {
            originalImage = imageView.image
            imageView.image = openedImage
        }
        cells().forEach { insert(cell: $0) }
        cellAnimationWithOpen(self)
        isClosed = false
    }
    
    @objc public func close() {
        backgroundView.removeFromSuperview()
        if openedImage == nil {
            btnAnimationWithClose(self)
        } else {
            imageView.image = closedImage
            originalImage = nil
        }
        cellAnimationWothClose(self)
        isClosed = true
    }
    
    
    // MARK: - Private
    private func setup() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        setupCircleLayer()
        
        imageView.clipsToBounds = false
        self.addSubview(imageView)
        resizeSubviews()
    }
    
    private func resizeSubviews() {
        let size = CGSize(width: frame.width * 0.5, height: frame.height * 0.5)
        imageView.frame = CGRect(x: frame.width - frame.width * internalRatio, y: frame.height - frame.height * internalRatio,
                                 width: size.width, height: size.height)
    }
    
    private func responseCircle() {
        if touching && responsible {
            circleLayer.backgroundColor = touchingColor?.cgColor ?? color.withAlphaComponent(0.5).cgColor
        } else {
            circleLayer.backgroundColor = color.cgColor
        }
    }
    
    private func setupCircleLayer() {
        circleLayer.removeFromSuperlayer()
        circleLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        circleLayer.backgroundColor = color.cgColor
        circleLayer.cornerRadius = size / 2
        layer.addSublayer(circleLayer)
    }
    
    private func insert(cell: KKFloatingActionButtonCell) {
        cell.alpha = 0
        switch cellHorizontalAlign {
        case .center:
            cell.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        case .left:
            cell.frame.origin.x = 0
            cell.frame.origin.y = self.frame.size.height/2 - cell.frame.size.height/2
        case .right:
            cell.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            cell.frame.origin.x = self.frame.size.width - cell.frame.size.width
        }
        cell.actionButton = self
        self.addSubview(cell)
    }
    
    private func isTouched(_ touches: Set<UITouch>) -> Bool {
        return touches.count == 1 && touches.first?.tapCount == 1 && touches.first?.location(in: self) != nil
    }
    
    
    // MARK: - Action
    func didTap(cell: KKFloatingActionButtonCell) {
        guard let _ = dataSource else { return }
        cells().enumerated()
            .filter { $1 === cell }
            .forEach { index, _ in delegate?.floatingActionButton?(self, didSelectItemAtIndex: index) }
    }
    
    // MARK: - Event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touching = true
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouched(touches) {
            isClosed ? open() : close()
        }
        self.touching = false
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        self.touching = false
        setNeedsDisplay()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for cell in cells() {
            if !self.subviews.contains(cell) { continue }
            let pointForTargetView = cell.convert(point, from: self)
            
            if cell.bounds.contains(pointForTargetView) {
                if cell.isUserInteractionEnabled {
                    return cell.hitTest(pointForTargetView, with: event)
                }
            }
        }
        
        return super.hitTest(point, with: event)
    }
}


// MARK: - animation
extension KKFloatingActionButton {
    // MARK: - cell
    public func popCellAnimationWithOpen() {
        var cellHeight = btnToCellMargin
        var delay = 0.0
        cells().forEach { cell in
            cellHeight += cell.size + cellMargin
            cell.frame.origin.x = -cellHeight
            cell.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
            UIView.animate(withDuration: 0.3, delay: delay, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.3,
                           options: UIView.AnimationOptions(),
                           animations: {
                            cell.layer.transform = CATransform3DIdentity
                            cell.alpha = 1
            }, completion: nil)
            delay += 0.1
        }
    }
    
    public func popCellAnimationWithClose() {
        var delay = 0.0
        cells().forEach { cell in
            UIView.animate(withDuration: 0.15, delay: delay, options: UIView.AnimationOptions(), animations: {
                cell.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
                cell.alpha = 0
            }, completion: { _ in
                cell.layer.transform = CATransform3DIdentity
            })
            delay += 0.1
        }
    }
    
    // MARK: - button
    public func rotate45BtnAnimationWithOpen() {
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * 45.0 / 180.0)
        }
    }
    
    public func rotate45BtnAnimationWithClose() {
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * 0 / 180.0)
        }
    }
}
