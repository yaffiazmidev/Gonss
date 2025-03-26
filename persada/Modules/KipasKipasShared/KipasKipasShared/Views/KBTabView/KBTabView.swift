//
//  Created by BK @kitabisa.
//

import UIKit

public class KBTabView<Layout: KBTabViewLayout, Item: KBTabViewItemable, Cell: KBTabViewBaseCell>: UIView {
    
    private(set) public var layout = Layout()
    
    public var hideLeftIconWhenUnselected: Bool = false
    
    // MARK: [KBPL] Replace indexPath-based value to `KBTabViewItemable` to set the default selected tab
    private var defaultSelectedTabIndex: Int
    
    public weak var delegate: KBTabViewDelegate? {
        didSet {
            configurator.selection.delegate = delegate
        }
    }
    
    private var containerView: KBTabContainerView!
    
    private var collectionView: UICollectionView!
    
    private var configurator: (dataSource: KBTabViewDataSource<Item, Cell>, selection: KBTabViewSelectionConfigurator<Item, Cell>)!
    
    // MARK: Initializer
    public init(
        size: CGSize,
        position: CGFloat,
        defaultSelectedTabIndex: Int = 0
    ) {
        self.defaultSelectedTabIndex = defaultSelectedTabIndex
        super.init(frame: CGRect(
            x: 0,
            y: position,
            width: size.width,
            height: size.height
        ))
        configureCollectionView()
        containerView = KBTabContainerView(with: collectionView)
        containerView.frame = frame
        
        addSubview(containerView)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setNeedsLayoutUpdate(_:)),
            name: KBTabViewNeedsLayoutUpdateNotification,
            object: nil
        )
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        layout.setNeedsUpdate()
    }
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("Use init(size:, position:)")
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(size:, position:)")
    }
    
    // MARK: Privates
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
        collectionView.alwaysBounceVertical = false
        
        let selectionConfigurator = KBTabViewSelectionConfigurator<Item, Cell>(
            oldSelectedIndex: IndexPath(
                item: defaultSelectedTabIndex,
                section: 0
            ))
        
        let isLayoutFixed = layout is KBTabViewFixedLayout
        let dataSource = KBTabViewDataSource<Item, Cell>(
            collectionView: collectionView,
            provider: { [weak self] collection, indexPath, item in
                guard let self = self else { return nil }
                
                let cell = collection.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as? Cell
                cell?.view.isLoading = item.isLoading
                cell?.view.configureLabel(isLayoutFixed)
                cell?.view.configureBadgeView(isLayoutFixed, badgeValue: item.badgeValue)
                cell?.view.titleLabel.text = item.title
                cell?.setSelected = !item.isLoading && item.isSelected
                cell?.view.configureLeftIcon(model: item.leftIconModel)
                cell?.hideLeftIconWhenUnselected = self.hideLeftIconWhenUnselected
                
                return cell
            })
        
        configurator = (dataSource, selectionConfigurator)
        collectionView.dataSource = configurator.dataSource
        collectionView.delegate = configurator.selection
    }
    
    private func configure(items: [Item]) {
        guard !items.isEmpty else { return }
        
        layout.numberOfItems = items.count
        configurator.dataSource.reload(with: items)
        configurator.selection.oldItems = items
    }
    
    public func setBadgeValue(_ count: Int, at index: Int) {
        configurator.selection.setBadgeValue(count, at: index)
        collectionView.reloadData()
    }
    
    public func replaceItem(with item: Item, at index: Int) {
        var newItems = configurator.selection.oldItems
        
        newItems[index] = item
        
        configurator.dataSource.reload(with: newItems)
        configurator.selection.oldItems = newItems
        
        collectionView.reloadData()
    }
    
    @objc private func setNeedsLayoutUpdate(_ notification: Notification) {
        guard let newLayout = notification.object as? Layout else {
            return
        }
        
        layout = newLayout
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.collectionViewLayout = newLayout.createLayout()
    }
    
    // MARK: Publics
    public func addItems(_ items: [Item]) {
        configure(items: items)
    }
    
    public func selectItem(at index: Int) {
        configurator.selection.collectionView(
            collectionView,
            didSelectItemAt: .init(item: index, section: 0)
        )
    }
}

extension KBTabView {
    public var errorView: UIView? {
        get { return nil }
        set {
            collectionView.backgroundView = newValue
        }
    }
}

