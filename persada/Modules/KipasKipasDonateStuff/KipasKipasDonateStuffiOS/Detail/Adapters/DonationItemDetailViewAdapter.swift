import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

protocol DonationItemDetailViewAdapterDelegate: AnyObject {
    func display(
        sections: [CollectionSectionController],
        isProgressCompleted: Bool,
        isLoading: Bool
    )
    func display(title: String)
    func display(action donate: @escaping Closure<Int>)
}

final class DonationItemDetailViewAdapter: ResourceView, ResourceLoadingView {
    
    private typealias Item = CollectionCellController
    private typealias Section = CollectionSectionController
    private typealias ViewModel = DonationItemDetailViewModel
    
    weak var delegate: DonationItemDetailViewAdapterDelegate?
    
    private let imageLoader: ImageResourceLoader
    private let didDonate: Closure<(DonationItemDetailViewModel, Int)>
    private let role: DonationItemRole
    
    init(
        imageLoader: ImageResourceLoader,
        didDonate: @escaping Closure<(DonationItemDetailViewModel, Int)>,
        role: DonationItemRole
    ) {
        self.imageLoader = imageLoader
        self.didDonate = didDonate
        self.role = role
    }
    
    func display(view viewModel: DonationItemDetailViewModel) {
        delegate?.display(title: viewModel.info.itemName)
        delegate?.display(
            sections: [
                makeImageSection(viewModel),
                makeInfoSection(viewModel),
                makeDividerSection(),
                makeStakeholderSection(viewModel),
                makeDividerSection(),
                makeDividerSection(color: .white),
                makeDescriptionSection(viewModel)
            ],
            isProgressCompleted: viewModel.info.collectionCompleted,
            isLoading: false
        )
        
        delegate?.display { [didDonate] quantity in
            didDonate((viewModel, quantity))
        }
    }
    
    func display(loading viewModel: ResourceLoadingViewModel) {
        delegate?.display(
            sections: makeDonationItemDetailLoadingSections(),
            isProgressCompleted: false,
            isLoading: true
        )
    }
}

// MARK: Section Factory
extension DonationItemDetailViewAdapter {
    private func makeImageSection(_ viewModel: ViewModel) -> Section {
        let items: [Item] = viewModel.productImages.map { [imageLoader] model in
            let adapter = ImagePresentationAdapter<DonationItemDetailImageCellController>(loader: imageLoader)
            let view = DonationItemDetailImageCellController(
                viewModel: model,
                imageAdapter: adapter
            )
            adapter.presenter = LoadResourcePresenter(
                view: view,
                transformer: UIImage.tryMake
            )
            return Item(view)
        }
        
        return Section(
            cellControllers: items,
            sectionType: DonationItemDetailSection.photos.rawValue
        )
    }
    
    private func makeInfoSection(_ viewModel: ViewModel) -> Section {
        let items: [Item] = [viewModel.info].map { [role] model in
            let view = DonationItemDetailInfoCellController(
                viewModel: model, 
                role: role
            )
            return Item(id: model.itemId, view)
        }
        
        return Section(
            cellControllers: items,
            sectionType: DonationItemDetailSection.info.rawValue
        )
    }
    
    private func makeStakeholderSection(_ viewModel: ViewModel) -> Section {
        let adapter = ImagePresentationAdapter<DonationItemDetailStakeholderCellController>(loader: imageLoader)
        let view = DonationItemDetailStakeholderCellController(
            viewModel: viewModel.stakeholder,
            imageAdapter: adapter
        )
        adapter.presenter = LoadResourcePresenter(
            view: view,
            transformer: UIImage.tryMake
        )
        
        let item = Item(view)
        
        return Section(
            cellControllers: [item],
            sectionType: DonationItemDetailSection.stakeholder.rawValue
        )
    }
    
    private func makeDescriptionSection(_ viewModel: ViewModel) -> Section {
        let view = DonationItemDetailDescriptionCellController(viewModel: viewModel.desc)
        let item = Item(view)
        return Section(
            cellControllers: [item],
            sectionType: DonationItemDetailSection.description.rawValue
        )
    }
    
    private func makeDividerSection(color: UIColor = .alabaster) -> Section {
        let view = Divider(color: color, height: 4)
        let item = Item(view)
        
        return Section(
            cellControllers: [item],
            sectionType: DonationItemDetailSection.divider.rawValue
        )
    }
}
