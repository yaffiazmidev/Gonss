//
//  KipasKipas
//
//  Created by batm batmandiri on 18/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

protocol PopupReportDelegate where Self: UIViewController {

	func closePopUp(id: String, index: Int)
}

final class ReportPopupView: UIView {

    weak var delegate: PopupReportDelegate?
	var id: String = ""
	var index: Int = 0
    var onBackPressed: (() -> Void?)?
    
    lazy var reportImage: UIImageView = {
        let screenSize: CGRect = UIScreen.main.bounds
        let image = UIImageView()
        image.image = UIImage(named: String.get(.iconReportSuccess))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
        }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.bold, size: 14)
        label.text = String.get(.thanskReport)
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.bold, size: 10)
        label.text = String.get(.reportInfo)
        label.numberOfLines = 2
        label.textColor = .grey
        label.textAlignment = .center
        return label
    }()
    
    lazy var container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 8
        return v
    }()
    
    lazy var backButton : PrimaryButton = {
        let button = PrimaryButton()
        button.setup(font: .Roboto(.bold, size: 14))
        button.isEnabled = false
        button.isUserInteractionEnabled = true
        button.backgroundColor = .primary
        button.isEnabled = true
        button.setTitle(String.get(.back), for: .normal)
        button.addTarget(self, action: #selector(self.dismissPopUp), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.grey.withAlphaComponent(0.5)
        self.frame = UIScreen.main.bounds
        
        let stack = UIStackView(arrangedSubviews: [reportImage, titleLabel, subtitleLabel, backButton])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 25
        
        self.addSubview(container)
        
        
        container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7).isActive = true
        container.heightAnchor.constraint(equalToConstant: 342).isActive = true
        
        container.addSubview(stack)

        stack.anchor(top: container.topAnchor, left: container.leftAnchor, right: container.rightAnchor, paddingTop: 40, paddingLeft: 24, paddingBottom: 20, paddingRight: 24)
        
        backButton.anchor(top: subtitleLabel.bottomAnchor, left: nil, bottom: stack.bottomAnchor, right: nil, paddingTop: 24, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 214, height: 48)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func dismissPopUp() {
        self.onBackPressed?()
		delegate?.closePopUp(id: self.id, index: self.index)
    }
}
