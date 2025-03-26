import UIKit
import KipasKipasShared

final class ListDemoCellController: NSObject {
    
    private let model: ListDemo
    private let selection: Closure<String>
    
    private var cell: ListDemoCell?
    
    init(
        model: ListDemo,
        selection: @escaping Closure<String>
    ) {
        self.model = model
        self.selection = selection
    }
}

extension ListDemoCellController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.label.text = model.title
        return cell!
    }
}

extension ListDemoCellController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection(model.type)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

