import KipasKipasShared
import KipasKipasStory

final class StoryViewersViewAdapter: ResourceView, StoryViewersManagerDelegate {
    
    private let manager = StoryViewersManager.shared
    
    private weak var controller: StoryViewersViewController?
    
    init(controller: StoryViewersViewController) {
        self.controller = controller
    }
    
    // MARK: Callbacks
    var follow: Closure<String>?
    var sendMessage: Closure<String>?
    var showProfile: Closure<String>?
    
    func display(view viewModel: StoryViewerPagingViewModel) {
        if viewModel.viewers.isEmpty {
            configureEmptyCellController()
        } else {
            configureCellControllers(viewModel.viewers)
            manager.configure(viewModel.viewers, delegate: self)
        }
    }
    
    private func configureCellControllers(_ viewers: [StoryViewerViewModel]) {
        let controllers = viewers.map { viewer in
            let view = StoryViewerCellController(
                viewModel: viewer,
                delegate: self
            )
            let controller = CollectionCellController(view)
            return controller
        }
        
        let section = CollectionSectionController(
            cellControllers: controllers,
            sectionType: StoryViewersSection.viewers.rawValue
        )
        
        controller?.title = "Dilihat \(controllers.count) orang"
        controller?.display(sections: [section], isScrollEnabled: true)
    }
    
    private func configureEmptyCellController() {
        let viewModel = CollectionEmptyViewModel(message: "Belum dilihat")
        let emptyView = CollectionEmptyCellController(viewModel: viewModel)
        let cellController = CollectionCellController(emptyView)
        let section = CollectionSectionController(
            cellControllers: [cellController],
            sectionType: StoryViewersSection.empty.rawValue
        )
        
        controller?.title = "Dilihat 0"
        controller?.display(sections: [section], isScrollEnabled: false)
    }
    
    func reload() {
        configureCellControllers(manager.viewers)
    }
    
    deinit {
        StoryViewersManager.nullify()
    }
}

extension StoryViewersViewAdapter: StoryViewerCellControllerDelegate {
    func didTapFollow(viewer: inout StoryViewerViewModel) {
        defer { follow?(viewer.accountId) }
        manager.setFollow(for: &viewer)
    }
    
    func didTapSendMessage(viewer: StoryViewerViewModel) {
        sendMessage?(viewer.accountId)
    }
    
    func didTapProfile(viewer: StoryViewerViewModel) {
        showProfile?(viewer.accountId)
    }
}
