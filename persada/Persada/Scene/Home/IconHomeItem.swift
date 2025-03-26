import UIKit
import KipasKipasShared
import Kingfisher

struct HomeMenuItem: PagingItem, Hashable {
    
    struct Rect {
        let frame: CGRect
        let center: CGPoint
        
        static var zero: Self {
            .init(frame: .zero, center: .zero)
        }
    }
    
    var themeColor: UIColor
    let icon: UIImage?
    let index: Int
    let title: String
    let isExpanded: Bool
    var onTapDropdownMenu: ((Bool, Rect) -> Void)?
    
    /**
     Please use curly braces for onTapDropdownMenu with weak self so that it doesn't create a strong reference.
     
     - parameter with data: InAppPurchasePending.
     # Example #
     ```
     onTapDropdownMenu: { [weak self] isExpanded, rect in
         //your function
     }
     ```
     */
    init(
        themeColor: UIColor = .white,
        icon: UIImage? = nil,
        index: Int,
        title: String,
        isExpanded: Bool = false,
        onTapDropdownMenu: @escaping (Bool, Rect) -> Void = { _,_ in }
    ) {
        self.themeColor = themeColor
        self.icon = icon
        self.index = index
        self.title = title
        self.isExpanded = isExpanded
        self.onTapDropdownMenu = onTapDropdownMenu
    }
    
    static func == (lhs: HomeMenuItem, rhs: HomeMenuItem) -> Bool {
        return lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
    func isBefore(item: PagingItem) -> Bool {
        if let item = item as? PagingIndexItem {
            return index < item.index
        }
        
        if let item = item as? Self {
            return index < item.index
        }
        
        if let item = item as? HomeMenuItem {
            return index < item.index
        }
        
        if let item = item as? HomeMenuIconItem {
            return index < item.index
        }
        
        return false
    }
}

struct HomeMenuIconItem: PagingItem, Hashable {
    
    let url: String?
    let icon: UIImage?
    let index: Int
    let size: CGSize?
   
    init(
        url: String? = nil,
        icon: UIImage? = nil,
        index: Int,
        size: CGSize? = nil
    ) {
        self.url = url
        self.icon = icon
        self.index = index
        self.size = size
    }
    
    static func == (lhs: HomeMenuIconItem, rhs: HomeMenuIconItem) -> Bool {
        return lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
    func isBefore(item: PagingItem) -> Bool {
        if let item = item as? PagingIndexItem {
            return index < item.index
        }
        
        if let item = item as? Self {
            return index < item.index
        }
        
        if let item = item as? HomeMenuItem {
            return index < item.index
        }
        
        if let item = item as? HomeMenuIconItem {
            return index < item.index
        }
        
        return false
    }
}

class HomeMenucell: PagingCell {
    
    private let stackView = UIStackView()
    private let menuLabel = UILabel()
    private let iconView = UIButton()
    private let selectedLine = UIView()
    private let twoSelectedLine = UIImageView()
    
    private var item: HomeMenuItem?
    
    private var isExpanded: Bool = false {
        didSet {
            guard let item = item else { return }
            iconView.setImage(isExpanded ? .iconDropdownExpanded?.withTintColor(item.themeColor) : .iconDropdownCollapsed?.withTintColor(item.themeColor))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       configureUI()
    }
    
    // MARK: UI
    private func configureUI() {
        configureStackView()
        configureMenuLabel()
        configureIconView()
        configureSelectedLine()
        configureTwoSelectedLine()
    }
    
    private func configureStackView() {
        stackView.spacing = 0
        stackView.backgroundColor = .clear
        contentView.addSubview(stackView)
        
        stackView.anchors.edges.pin()
    }
    
    private func configureMenuLabel() {
        menuLabel.textAlignment = .center
        menuLabel.textColor = .white
        menuLabel.font = .roboto(.regular, size: 18)
        
        stackView.addArrangedSubview(menuLabel)
    }
    
    private func configureIconView() {
        iconView.backgroundColor = .clear
        iconView.addTarget(self, action: #selector(onTapIcon), for: .touchUpInside)
        
        stackView.addArrangedSubview(iconView)
    }
    
    private func configureSelectedLine() {
        selectedLine.backgroundColor = .white
        selectedLine.layer.cornerRadius = 1.5
        selectedLine.layer.masksToBounds = true
        
        contentView.addSubview(selectedLine)
        selectedLine.anchors.width.equal(18)
        selectedLine.anchors.leading.greaterThanOrEqual(contentView.anchors.leading)
        selectedLine.anchors.trailing.lessThanOrEqual(contentView.anchors.trailing)
        
        selectedLine.anchors.height.equal(3)
        selectedLine.anchors.centerX.align()
        selectedLine.anchors.bottom.equal(stackView.anchors.bottom)
    }
    
    private func configureTwoSelectedLine() {
        twoSelectedLine.backgroundColor = .clear
        twoSelectedLine.image = UIImage(named: "feed_line_white")?.withRenderingMode(.alwaysTemplate)
        contentView.addSubview(twoSelectedLine)
        twoSelectedLine.anchors.width.equal(16)
        twoSelectedLine.anchors.height.equal(11)
        twoSelectedLine.anchors.centerX.align()
        twoSelectedLine.anchors.bottom.equal(stackView.anchors.bottom)
    }
    
    @objc private func onTapIcon() {
        isExpanded.toggle()
        item?.onTapDropdownMenu?(isExpanded, .init(frame: frame, center: center))
    }
    
    override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
        if let item = pagingItem as? HomeMenuItem {
            menuLabel.text = item.title
            menuLabel.textAlignment = item.icon == nil ? .center : selected ? .left : .center
            iconView.anchors.width.equal(15)
            iconView.anchors.height.equal(15)
            
            if selected {
                menuLabel.textColor = options.selectedTextColor
                menuLabel.font = .roboto(.bold, size: 18)
//                iconView.isHidden = false
                iconView.isEnabled = true
            } else {
                menuLabel.textColor = options.textColor
                menuLabel.font = .roboto(.regular, size: 18)
//                iconView.isHidden = true
                iconView.isEnabled = false
            }
            
            self.item = item
            
            isExpanded = item.isExpanded
            if item.index == 1 {
                iconView.isHidden = false
            } else if item.index == 2 {
                iconView.isHidden = false
            } else {
                iconView.isHidden = true
            }
            
            twoSelectedLine.isHidden = !(selected && item.title == "Feed")
            twoSelectedLine.tintColor = options.selectedTextColor
            selectedLine.isHidden = !(selected && item.title != "Feed")
            selectedLine.backgroundColor = options.selectedTextColor
        }
        
        if let item = pagingItem as? HomeMenuIconItem {
            let size = item.size ?? .init(width: 24, height: 24)
            iconView.anchors.width.equal(size.width)
            iconView.anchors.height.equal(size.height)
            iconView.anchors.center.align()
            iconView.isEnabled = false
            iconView.setImage(item.icon, for: .normal)
            iconView.setImage(item.icon, for: .disabled)
            
            if let string = item.url, let url = URL(string: string) {
                KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                    guard let self = self else { return }
                    if case .success(let image) = result {
                        self.iconView.setImage(image.image, for: .normal)
                        self.iconView.setImage(image.image, for: .disabled)
                    }
                }
            }
        }
    }
}



struct IconHomeItem: PagingItem, Hashable {
    let icon: String
    let index: Int
    let image: UIImage?

    init(icon: String, index: Int) {
        self.icon = icon
        self.index = index
        image = UIImage(named: icon)
    }

    /// By default, isBefore is implemented when the PagingItem conforms
    /// to Comparable, but in this case we want a custom implementation
    /// where we also compare IconHomeItem with PagingIndexItem. This
    /// ensures that we animate the page transition in the correct
    /// direction when selecting items.
    func isBefore(item: PagingItem) -> Bool {
        if let item = item as? PagingIndexItem {
            return index < item.index
        }
        
        if let item = item as? Self {
            return index < item.index
        }
        
        if let item = item as? HomeMenuItem {
            return index < item.index
        }
        
        if let item = item as? HomeMenuIconItem {
            return index < item.index
        }
        
        return false
    }
}


struct IconPagingCellViewModel {
    let image: UIImage?
    let selected: Bool
    let tintColor: UIColor
    let selectedTintColor: UIColor

    init(image: UIImage?, selected: Bool, options: PagingOptions) {
        self.image = image
        self.selected = selected
        tintColor = options.textColor
        selectedTintColor = options.selectedTextColor
    }
}

class IconPagingCell: PagingCell {
    fileprivate var viewModel: IconPagingCellViewModel?

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
        if let item = pagingItem as? IconHomeItem {
            let viewModel = IconPagingCellViewModel(
                image: item.image,
                selected: selected,
                options: options
            )

            imageView.image = viewModel.image

            self.viewModel = viewModel
        }
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
    }
}

extension UILabel {
    class func textSize(font: UIFont, text: String) -> (width: CGFloat, height: CGFloat) {
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        let width = ceil(labelSize.width)
        let height = ceil(labelSize.height)
    
        return (width, height)
    }
}
