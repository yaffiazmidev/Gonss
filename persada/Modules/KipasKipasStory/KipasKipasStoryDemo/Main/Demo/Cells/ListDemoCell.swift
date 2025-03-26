import UIKit
import KipasKipasShared

final class ListDemoCell: UITableViewCell {
    
    let label = UILabel()
    
    private let bottomLineView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: UI
    private func configureUI() {
        configureLabel()
        configureBottomLineView()
    }
    
    private func configureLabel() {
        label.font = .roboto(.medium, size: 16)
        label.textColor = .night
        
        addSubview(label)
        label.anchors.edges.pin(insets: 16, axis: .horizontal)
        label.anchors.edges.pin(insets: 8, axis: .vertical)
    }
    
    private func configureBottomLineView() {
        bottomLineView.backgroundColor = .softPeach
        
        addSubview(bottomLineView)
        bottomLineView.anchors.bottom.pin()
        bottomLineView.anchors.height.equal(1)
        bottomLineView.anchors.edges.pin(insets: 12, axis: .horizontal)
    }
}
