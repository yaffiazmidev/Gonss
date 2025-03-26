//
//  Created by BK @kitabisa.
//

import UIKit

public final class KBTabViewMenuCell: KBTabViewBaseCell {
    
    private let lineView = UIView()
    
    private var lineViewHeight: NSLayoutConstraint? {
        didSet {
            lineViewHeight?.isActive = true
        }
    }
    
    public override var setSelected: Bool {
        didSet {
            set(setSelected)
            layoutIfNeeded()
        }
    }
    
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
        configureLineView()
    }
    
    private func configureMainView() {
        view = KBTabMenuView()
        view.backgroundColor = .white
        
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func configureLineView() {
        contentView.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        lineViewHeight = lineView.heightAnchor.constraint(equalToConstant: 2)
    }
    
    private func set(_ isSelected: Bool) {
        if isSelected {
            setSelectedStyle()
        } else {
            setDefaultStyle()
        }
    }
    
    private func setSelectedStyle() {
        view.titleLabel.font = .roboto(.bold, size: 16)
        view.titleLabel.textColor = .gravel
        lineView.backgroundColor = .gainsboro
        lineViewHeight?.constant = 2
    }
    
    private func setDefaultStyle() {
        view.titleLabel.font = .roboto(.bold, size: 16)
        view.titleLabel.textColor = .ashGrey
        lineView.backgroundColor = .white
        lineViewHeight?.constant = 1
    }
}
