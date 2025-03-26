//
//  Created by BK @kitabisa.
//

import UIKit

public final class KBTabViewSegmentedCell: KBTabViewBaseCell {
    
    private let containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Use init(frame:)")
    }
    
    private func configure() {
        configureMainView()
        configureContainerView()
    }
    
    private func configureMainView() {
        view = KBTabMenuView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func configureContainerView() {
        containerView.addSubview(view)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        view.leftPadding = 16
        view.rightPadding = 16
        view.titleLabel.font = .roboto(.medium, size: 14)
        view.titleLabel.textColor = .night
        
        containerView.backgroundColor = .white
        containerView.layer.borderColor = UIColor.gainsboro.cgColor
        containerView.layer.borderWidth = 1
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 4
    }
}
