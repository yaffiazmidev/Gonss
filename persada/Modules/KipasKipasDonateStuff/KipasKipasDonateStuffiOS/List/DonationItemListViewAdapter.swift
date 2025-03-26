import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

protocol DonationItemListViewAdapterDelegate: AnyObject {
    func display(
        sections: [TableSectionController],
        isLoading: Bool
    )
}

final class DonationItemListViewAdapter: ResourceView, ResourceLoadingView {
        
    weak var delegate: DonationItemListViewAdapterDelegate?
    
    private var items: [DonationItemViewModel] = []
    
    private let imageLoader: ImageResourceLoader
    private let currentFeed: [DonationItemViewModel: TableCellController]
    private let role: DonationItemRole
    private let selection: Closure<(String, DonationItemRole)>
    
    init(
        currentFeed: [DonationItemViewModel: TableCellController] = [:],
        imageLoader: ImageResourceLoader,
        role: DonationItemRole,
        selection: @escaping Closure<(String, DonationItemRole)>
    ) {
        self.currentFeed = currentFeed
        self.imageLoader = imageLoader
        self.role = role
        self.selection = selection
    }
    
    func display(view viewModel: DonationItemListViewModel) {
        items = viewModel.items
        display(from: viewModel)
    }
    
    func display(loading loadingViewModel: ResourceLoadingViewModel) {
        let skeletonSections = TableSkeletonCell<DonationItemListCell>.sections(count: 8, height: 80)
        delegate?.display(
            sections: skeletonSections,
            isLoading: true
        )
    }
    
    func filter(query: String) {
        let results = items.filter { item in
            item.itemName.range(of: query, options: .caseInsensitive) != nil
        }
        let items = query.isEmpty ? items : results
        
        display(from: .init(items: items))
    }
    
    private func display(from viewModel: DonationItemListViewModel) {
        var currentFeed = self.currentFeed
        
        let controllers: [TableCellController] = viewModel.items.map { [imageLoader, role, selection] model in
            if let controller = currentFeed[model] {
                return controller
            }
            
            let adapter = ImagePresentationAdapter<DonationItemCellController>(loader: imageLoader)
            let view = DonationItemCellController(
                viewModel: model,
                imageAdapter: adapter,
                role: role,
                selection: selection
            )
            
            adapter.presenter = LoadResourcePresenter(
                view: view,
                transformer: UIImage.tryMake(dict:)
            )
            
            let controller = TableCellController(id: model.itemId, view)
            currentFeed[model] = controller
            return controller
        }
        
        let section = TableSectionController(cellControllers: controllers)
        
        delegate?.display(
            sections: [section],
            isLoading: false
        )
    }
}
