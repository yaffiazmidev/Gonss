import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

public final class GiftBoxDummyViewController: UIViewController {
    
    private lazy var giftBoxListView = GiftBoxListView()
    
    public var didSelectGiftBox: Closure<GiftBoxViewModel>?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray4
        
        view.addSubview(giftBoxListView)
        giftBoxListView.didSelectGiftBox = { [weak self] in self?.didSelectGiftBox?($0) }
        giftBoxListView.anchors.top.equal(view.safeAreaLayoutGuide.anchors.top)
        giftBoxListView.anchors.leading.pin(inset: 12)
        giftBoxListView.anchors.height.equal(35)
        
        giftBoxListView.configure()
    }
}

final class GiftBoxListView: UIView {
    
    private var items: [CollectionCellController] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 6
        layout.itemSize = .init(width: 35, height: 35)
        layout.scrollDirection = .horizontal
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    var didSelectGiftBox: Closure<GiftBoxViewModel>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        observeContentSizeChanges()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    private func observeContentSizeChanges() {
        collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), options: [.new, .initial], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UICollectionView.contentSize) {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionView.contentSize
    }
    
    deinit {
        collectionView.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize))
    }
    
    // MARK: API
    func configure() {
        items = giftBoxViewModelMocks.map { viewModel in
            let view = GiftBoxListCellController(
                viewModel: viewModel,
                delegate: self
            )
            let controller = CollectionCellController(view)
            return controller
        }
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension GiftBoxListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let ds = items[indexPath.item].dataSource
        return ds.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

// MARK: UICollectionViewDelegate
extension GiftBoxListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dl = items[indexPath.item].delegate
        dl?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
}

// MARK: GiftBoxListCellControllerDelegate
extension GiftBoxListView: GiftBoxListCellControllerDelegate {
    func didSelectGiftBox(_ viewModel: GiftBoxViewModel) {
        didSelectGiftBox?(viewModel)
    }
}

// MARK: UI
private extension GiftBoxListView {
    func configureUI() {
        backgroundColor = .clear
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        
        collectionView.registerCell(GiftBoxListCell.self)
        
        addSubview(collectionView)
        collectionView.anchors.edges.pin()
    }
}
