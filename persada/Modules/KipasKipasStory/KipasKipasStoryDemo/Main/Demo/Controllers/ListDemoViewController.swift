import UIKit
import KipasKipasShared

final class ListDemoViewController: TableListController {

    private let selection: Closure<String>
    
    init(selection: @escaping Closure<String>) {
        self.selection = selection
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "Story Demo")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.separatorStyle = .none
        tableView.registerCell(ListDemoCell.self)
        
        setData()
    }
    
    // MARK: Helpers
    private func setData() {
        let models: [ListDemo] = [
            .init(title: "Camera Story", type: StoryDemoType.cameraStory.rawValue),
            .init(title: "Create Story", type: StoryDemoType.createStory.rawValue),
            .init(title: "Detail Story", type: StoryDemoType.detailStory.rawValue),
            .init(title: "List Story", type: StoryDemoType.listStory.rawValue)
        ]
        
        let controllers: [TableCellController] = models.map { [selection] model in
            let view = ListDemoCellController(
                model: model,
                selection: selection
            )
            let controller = TableCellController(view)
            return controller
        }
        
        let section = TableSectionController(cellControllers: controllers)
        display(sections: [section])
    }
}

