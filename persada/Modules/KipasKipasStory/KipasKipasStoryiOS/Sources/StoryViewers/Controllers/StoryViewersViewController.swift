import UIKit
import KipasKipasShared
import KipasKipasStory

final class StoryViewersViewController: CollectionListController {
    
    var deleteStory: EmptyClosure?
    var onViewWillAppear: EmptyClosure?
    
    lazy var viewAdapter = StoryViewersViewAdapter(controller: self)
    let followAdapter = StoryFollowViewAdapter()
    
    override var title: String? {
        didSet {
            setupNavigationBar(
                title: title ?? "",
                color: .white,
                tintColor: .night
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onViewWillAppear?()
    }
    
    override func viewDidLoad() {
        refreshView.setLoading(true, tintColor: .watermelon)
        
        super.viewDidLoad()
        configureUI()
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(
            sectionProvider: { [unowned self] index, _ in
                guard let type = self.sectionType(at: index) else { return nil }
                return NSCollectionLayoutSection.layout(for: type)
            }
        )
    }
    
    private func sectionType(at index: Int) -> StoryViewersSection? {
        guard let section = sectionController(at: index) else { return nil }
        return .init(rawValue: section.sectionType)
    }
    
    @objc private func didPullToRefresh() {
        refreshView.setLoading(true, tintColor: .watermelon)
        onRefresh?()
    }
    
    @objc private func didTapDeleteButton() {
        showDeleteAlertConfirmation()
    }
    
    @objc private func didTapCloseButton() {
        NotificationCenter.default.post(name: VideoPlayerView.shouldResumeWhenVisible, object: nil)
        NotificationCenter.default.post(name: StoryPlayView.shouldResumeWhenVisible, object: nil)
        forceDismiss()
    }
    
    private func showDeleteAlertConfirmation() {
        let deleteAction = UIAlertAction(title: "Hapus", style: .destructive) { [weak self] _ in
            self?.forceDismiss(animated: true) { [weak self] in
                self?.deleteStory?()
            }
        }
        deleteAction.titleTextColor = .primary
        
        let cancelAction = UIAlertAction(title: "Batalkan", style: .cancel, handler: nil)
        cancelAction.titleTextColor = .grey
        
        showAlertController(
            title: "Hapus Story ini?",
            titleFont: .roboto(.bold, size: 14),
            backgroundColor: .white,
            actions: [deleteAction, cancelAction]
        )
    }
    
    // MARK: API
    override func display(
        sections: [CollectionSectionController],
        isScrollEnabled: Bool
    ) {
        super.display(sections: sections, isScrollEnabled: isScrollEnabled)
        refreshView.setLoading(false, tintColor: .watermelon)
    }
}

// MARK: UI
private extension StoryViewersViewController {
    func configureUI() {
        configureBarButtonItems()
        configureCollectionView()
    }
    
    func configureBarButtonItems() {
        let deleteButton = KKBaseButton()
        deleteButton.setImage(UIImage.Story.iconTrashOutlineBlack)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        
        let closeButton = KKBaseButton()
        closeButton.setImage(UIImage.Story.iconX?.withTintColor(.night))
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
 
        navigationItem.leftBarButtonItem = .init(customView: deleteButton)
        navigationItem.rightBarButtonItem = .init(customView: closeButton)
    }
    
    func configureCollectionView() {
        refreshView.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        collectionView.backgroundColor = .white
        collectionView.setCollectionViewLayout(makeLayout(), animated: false)
        collectionView.refreshControl = refreshView
        collectionView.contentInset.top = 10
        
        collectionView.registerCell(CollectionEmptyCell.self)
        collectionView.registerCell(StoryViewerCell.self)
    }
}
