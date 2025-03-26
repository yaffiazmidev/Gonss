import UIKit

public struct KKPageMenuStyle {
    public var indicatorPendingHorizontal: CGFloat  = 16
    public var indicatorPendingVertical: CGFloat    = 10
    public var titlePendingHorizontal: CGFloat      = 20
    public var titlePendingVertical: CGFloat        = 10
    public var indicatorColor = UIColor(white: 0.9, alpha: 1)
    public var indicatorStyle: KKPageMenuIndicatorStyle = .cover(widthType:.sizeToFit(minWidth: 10))
    public var indicatorCorner: KKPageMenuIndicatorCornerStyle = .semicircle
    public var labelWidthType: KKPageMenuItemWidthType = .sizeToFit(minWidth: 50)
    public var indicatorWidthType: KKPageMenuItemWidthType {
        get { return indicatorStyle.widthType }
    }
    public var titleFont = UIFont.boldSystemFont(ofSize: 14)
    public var selectedTitleFont = UIFont.boldSystemFont(ofSize: 14)
    public var normalTitleColor = UIColor.lightGray
    public var selectedTitleColor = UIColor.darkGray
    
    public init() {}
}


public class KKPageMenu: UIControl {
    
    public typealias PageMenuSelectedCallback = ((Int) -> Void)
    
    public var style: KKPageMenuStyle = .init() {
        didSet {
            reloadData()
        }
    }
    
    public var titles: [String] = [] {
        didSet {
            guard oldValue != titles else { return }
            reloadData()
            setSelectIndex(index: 0, animated: true)
        }
    }
    
    public var valueChange: PageMenuSelectedCallback?
    
    public var isScrollEnable: Bool {
        set {
            scrollView.isScrollEnabled = newValue
        }
        get {
            return scrollView.isScrollEnabled
        }
    }
    
    fileprivate var titleLabels: [UILabel] = []
    
    public private(set) var selectIndex = 0
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.bounces = true
        view.isPagingEnabled = false
        view.scrollsToTop = false
        view.isScrollEnabled = true
        view.contentInset = UIEdgeInsets.zero
        view.contentOffset = CGPoint.zero
        view.scrollsToTop = false
        return view
    }()
    
    private let selectContent =  UIView()
    
    private var indicator: UIView = {
        let ind = UIView()
        ind.layer.masksToBounds = true
        return ind
    }()
    
    private let selectedLabelsMaskView: UIView = {
        let cover = UIView()
        cover.layer.masksToBounds = true
        cover.isHidden = true
        return cover
    }()
    
    private var indicatorFrames: [CGRect] = []
    private var titleLabelFrames: [CGRect] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.style = KKPageMenuStyle()
        self.titles = []
        shareInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.style = KKPageMenuStyle()
        self.titles = []
        super.init(coder: aDecoder)
        shareInit()
    }
    
    
    private func shareInit() {
        addSubview(UIView()) // fix automaticallyAdjustsScrollViewInsets bug
        addSubview(scrollView)
        addBottomLine()
        reloadData()
    }
    
    func addBottomLine() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        bottomLine.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
        layer.addSublayer(bottomLine)
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let x = gesture.location(in: self).x + scrollView.contentOffset.x
        for (i, label) in titleLabels.enumerated() {
            if x >= label.frame.minX && x <= label.frame.maxX {
                setSelectIndex(index: i, animated: true)
                break
            }
        }
        
    }
    
    private func clearData() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        selectContent.subviews.forEach { $0.removeFromSuperview() }
        if let gescs = gestureRecognizers {
            for gesc in gescs {
                removeGestureRecognizer(gesc)
            }
        }
        titleLabels.removeAll()
    }
    
    private func reloadData() {
        clearData()
        guard self.titles.count > 0  else {
            return
        }
        UIView.animate(withDuration: 0.2) {
            self.setupItems()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(KKPageMenu.handleTapGesture(_:)))
        
        addGestureRecognizer(tapGesture)
        applySelected(index: 0, animated: true)
    }
    
    private func setupItems() {
        selectedLabelsMaskView.backgroundColor = UIColor.white
        scrollView.frame = bounds
        selectContent.frame = bounds
        selectContent.layer.mask = selectedLabelsMaskView.layer
        selectedLabelsMaskView.isUserInteractionEnabled = true
        
        createLabels()
        
        indicator.backgroundColor = style.indicatorColor
        scrollView.addSubview(indicator)
        scrollView.addSubview(selectContent)
    }
    
    private func createLabels() {
        
        indicatorFrames.removeAll()
        titleLabelFrames.removeAll()
        
        let font  = style.titleFont
        var labelX: CGFloat = 0
        let labelH = bounds.height
        let labelY: CGFloat = 0
        var labelW: CGFloat = 0
        
        let labelWidthIsFixed = style.labelWidthType.isFixed
        
        for (index, title) in titles.enumerated() {
            
            let titleSize = title.size(with: font)
            
            if labelWidthIsFixed {
                labelW = style.labelWidthType.width
            } else {
                labelW = titleSize.width + titlePendingHorizontal
                let minWidth = style.labelWidthType.width
                if labelW < minWidth { labelW = minWidth }
            }
            
            labelX = (titleLabels.last?.frame.maxX ?? 0 )
            
            let rect = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
            
            let backLabel = UILabel(frame: CGRect.zero)
            backLabel.tag = index
            backLabel.text = title
            backLabel.textColor = style.normalTitleColor
            backLabel.font = style.titleFont
            backLabel.textAlignment = .center
            backLabel.frame = rect
            
            let frontLabel = UILabel(frame: CGRect.zero)
            frontLabel.tag = index
            frontLabel.text = title
            frontLabel.textColor = style.selectedTitleColor
            frontLabel.font = style.titleFont
            frontLabel.textAlignment = .center
            frontLabel.frame = rect
            
            titleLabelFrames.append(rect)
            titleLabels.append(backLabel)
            scrollView.addSubview(backLabel)
            selectContent.addSubview(frontLabel)
            
            createIndicatorFrame(with: index, textSize: titleSize, label: frontLabel)
        }
        scrollView.contentSize.width = titleLabelFrames.last!.maxX
        selectContent.frame.size.width = titleLabelFrames.last!.maxX
    }
    
    private func createIndicatorFrame(with index: Int, textSize: CGSize, label: UILabel) {
        
        let indicatorWidthIsFixed = style.indicatorWidthType.isFixed
        
        switch style.indicatorStyle {
        case .cover:
            var coverW: CGFloat = 0
            var coverH: CGFloat = 0
            
            if indicatorWidthIsFixed {
                coverW = style.indicatorWidthType.width
                coverH = textSize.height + self.style.indicatorPendingVertical
            } else {
                coverW = textSize.width + self.style.indicatorPendingHorizontal
                coverH = textSize.height + self.style.indicatorPendingVertical
                
                let coverMinWidth = style.indicatorWidthType.width
                if coverW < coverMinWidth { coverW = coverMinWidth }
            }
            
            let coverSize = CGSize(width: coverW, height: coverH)
            let indicatorFrame = CGRect(center: label.center, size: coverSize)
            indicatorFrames.append(indicatorFrame)
            
        case let .line(widthType, position):
            var lineW: CGFloat = 0
            let lineH: CGFloat = position.height
            
            if indicatorWidthIsFixed {
                lineW = widthType.width
            }else {
                lineW = textSize.width + self.style.indicatorPendingHorizontal
                
                let lineMinWidth = widthType.width
                if lineW < lineMinWidth { lineW = lineMinWidth }
            }
            
            let lineSize = CGSize(width: lineW, height: lineH)
            
            var lineCenterY: CGFloat = 0
            switch position {
            case .top:
                lineCenterY = 0 + position.margin + lineH/2
            case .bottom:
                lineCenterY = label.frame.maxY - position.margin - (lineH/2.0)
            }
            
            let lineFrame = CGRect(center: CGPoint.init(x: label.center.x, y: lineCenterY), size: lineSize)
            indicatorFrames.append(lineFrame)
        }
    }
    
    private func applyIndicatorFrame(at index: Int, animated: Bool = true) {
        let indicatorFrame = self.indicatorFrames[index]
        let labelFrame = self.titleLabelFrames[index]
        
        let applyFrame = {
            self.indicator.frame = indicatorFrame
            self.selectedLabelsMaskView.frame = labelFrame
            self.applyIndicatorCorner()
        }
        
        if animated == true {
            UIView.animate(withDuration: 0.2) { applyFrame() }
        }else {
            applyFrame()
        }
    }
    
    private func applyIndicatorCorner() {
        switch style.indicatorCorner {
        case .none:
            indicator.layer.cornerRadius = 0
        case .semicircle:
            indicator.layer.cornerRadius = indicator.bounds.height / 2
        case .corner(let value):
            indicator.layer.cornerRadius = value
        }
    }
    
    fileprivate func applySelected(index: Int, animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            self.titleLabels.enumerated().forEach { selectedIndex, element in
                if index == selectedIndex {
                    element.font = self.style.selectedTitleFont
                    element.textColor = self.style.selectedTitleColor
                } else {
                    element.font = self.style.titleFont
                    element.textColor = self.style.normalTitleColor
                }
            }
            
            let currentLabel = self.titleLabels[index]
            let offSetX = min(max(0, currentLabel.center.x - self.bounds.width / 2),
                              max(0, self.scrollView.contentSize.width - self.bounds.width))
            self.scrollView.setContentOffset(CGPoint(x:offSetX, y: 0), animated: true)
            
            self.applyIndicatorFrame(at: index, animated: animated)
            
            self.selectIndex = index
            self.valueChange?(index)
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
}


public extension KKPageMenu {
    func setSelectIndex(index: Int, animated: Bool = true) {
        guard   index != selectIndex,
                index >= 0 ,
                index < titleLabels.count
        else    { return }
        
        applySelected(index: index, animated: animated)
    }
}

fileprivate extension KKPageMenu {
    func textSizeWithLabel(_ label: UILabel) -> CGSize {
        return label.text?.size(with: label.font) ?? .zero
    }
}

extension KKPageMenu {
    public var titleFont: UIFont {
        get { style.titleFont }
        set { style.titleFont = newValue }
    }
    
    public var selectedTitleFont: UIFont {
        get { style.selectedTitleFont }
        set { style.selectedTitleFont = newValue }
    }
    
    public var indicatorColor: UIColor {
        get { style.indicatorColor }
        set { style.indicatorColor = newValue }
    }
    
    public var titlePendingHorizontal: CGFloat {
        get { style.titlePendingHorizontal }
        set { style.titlePendingHorizontal = newValue }
    }
    
    public var titlePendingVertical: CGFloat  {
        get { style.titlePendingVertical }
        set { style.titlePendingVertical = newValue }
    }
    
    public var indicatorPendingHorizontal: CGFloat {
        get { style.indicatorPendingHorizontal }
        set { style.indicatorPendingHorizontal = newValue }
    }
    
    public var indicatorPendingVertical: CGFloat {
        get { style.indicatorPendingVertical }
        set { style.indicatorPendingVertical = newValue }
    }
    
    public var normalTitleColor: UIColor {
        get { style.normalTitleColor }
        set { style.normalTitleColor = newValue }
    }
    
    public var selectedTitleColor: UIColor {
        get { style.selectedTitleColor }
        set { style.selectedTitleColor = newValue }
    }
    
    public var labelWidthType: KKPageMenuItemWidthType {
        get { style.labelWidthType }
        set { style.labelWidthType = newValue }
    }
    
    public var indicatorStyle: KKPageMenuIndicatorStyle {
        get { style.indicatorStyle }
        set { style.indicatorStyle = newValue }
    }
}

fileprivate extension String {
    func size(with font: UIFont) -> CGSize {
        let aSize = CGSize(width: CGFloat(MAXFLOAT), height: 0.0)
        let rect = (self as NSString).boundingRect(with: aSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size
    }
}

fileprivate extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}
