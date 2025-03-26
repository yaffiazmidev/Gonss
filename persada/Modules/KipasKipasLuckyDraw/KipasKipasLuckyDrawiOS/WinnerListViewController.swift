import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

public final class WinnerListViewController: CollectionListController {
    
    private(set) lazy var listAdapter = WinnerListViewAdapter(controller: self)
    
    var winners: [WinnerViewModel] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        listAdapter.display(view: winners)
    }
    
    // MARK: Privates
    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(
            sectionProvider: { [unowned self] index, _ in
                guard let type = self.sectionType(at: index) else { return nil }
                return NSCollectionLayoutSection.layout(for: type)
            }
        )
    }
    
    private func sectionType(at index: Int) -> WinnerListSection? {
        guard let section = sectionController(at: index) else { return nil }
        return .init(rawValue: section.sectionType)
    }
}

// MARK: UI
private extension WinnerListViewController {
    func configureUI() {
        view.backgroundColor = .clear
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.setCollectionViewLayout(makeLayout(), animated: false)
        collectionView.contentInset.bottom = 10
        
        collectionView.registerCell(CollectionEmptyCell.self)
        collectionView.registerCell(WinnerListCell.self)
    }
}
