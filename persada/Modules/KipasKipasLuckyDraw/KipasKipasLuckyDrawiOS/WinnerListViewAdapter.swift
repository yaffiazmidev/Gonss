import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

final class WinnerListViewAdapter: ResourceView, ResourceLoadingView {
    
    private weak var controller: WinnerListViewController?
    
    init(controller: WinnerListViewController) {
        self.controller = controller
    }
    
    func display(view viewModel: [WinnerViewModel]) {
        if viewModel.isEmpty {
            configureEmptyCellController()
        } else {
            configureCellControllers(viewModel)
        }
    }
    
    func display(loading loadingViewModel: ResourceLoadingViewModel) {
        guard loadingViewModel.isLoading else { return }
        controller?.display(sections: WinnerListSection.skeletons)
    }
    
    private func configureCellControllers(_ viewModels: [WinnerViewModel]) {
        let controllers = viewModels.map { viewModel in
            let view = WinnerListCellController(viewModel: viewModel)
            let controller = CollectionCellController(view)
            return controller
        }
        let section = CollectionSectionController(
            cellControllers: controllers,
            sectionType: WinnerListSection.winners.rawValue
        )
        
        controller?.display(sections: [section], isScrollEnabled: true)
    }
    
    private func configureEmptyCellController() {
        let viewModel = CollectionEmptyViewModel(
            image: UIImage.LuckyDraw.iconEnvelope,
            message: "Belum ada pemenang",
            messageFont: .roboto(.regular, size: 13)
        )
        let emptyView = CollectionEmptyCellController(viewModel: viewModel)
        let cellController = CollectionCellController(emptyView)
        let section = CollectionSectionController(
            cellControllers: [cellController],
            sectionType: WinnerListSection.empty.rawValue
        )
        controller?.display(sections: [section], isScrollEnabled: false)
    }
}
