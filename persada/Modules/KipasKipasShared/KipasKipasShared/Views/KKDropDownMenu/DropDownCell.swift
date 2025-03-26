import UIKit

final class DropDownCell: UITableViewCell {
    
    private let containerView = UIView()
    private(set) var menuLabel = UILabel()
    private(set) var lineView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: UI
    private func configureUI() {
        configureContainerView()
        configureMenuLabel()
        configureLineView()
    }
    
    private func configureContainerView() {
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 6
        
        contentView.addSubview(containerView)
        containerView.anchors.edges.pin(axis: .horizontal)
        containerView.anchors.edges.pin(insets: 4, axis: .vertical)
    }
    
    private func configureMenuLabel() {
        menuLabel.textColor = .black
        menuLabel.font = .roboto(.regular, size: 18)
        menuLabel.textAlignment = .center
        
        containerView.addSubview(menuLabel)
        menuLabel.anchors.edges.pin()
        menuLabel.anchors.center.align()
    }
    
    private func configureLineView() {
        lineView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        contentView.addSubview(lineView)
        lineView.anchors.height.equal(1)
        lineView.anchors.edges.pin(axis: .horizontal)
        lineView.anchors.bottom.pin()
    }
}
