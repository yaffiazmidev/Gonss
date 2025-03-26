import UIKit

typealias TableCellAnimation = (UITableViewCell, IndexPath, UITableView) -> Void

final class TableViewAnimator {
    private let animation: TableCellAnimation
    
    init(animation: @escaping TableCellAnimation) {
        self.animation = animation
    }
    
    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        animation(cell, indexPath, tableView)
    }
}


enum TableAnimation {
    static func makeFadeAnimation(duration: TimeInterval) -> TableCellAnimation {
        return { cell, indexPath, tableView in
            cell.alpha = 0.0
            UIView.animate(
                withDuration: duration,
                delay: 0.15,
                options: [.curveEaseInOut, .transitionCrossDissolve],
                animations: {
                    cell.alpha = 1
            })
        }
    }
}

