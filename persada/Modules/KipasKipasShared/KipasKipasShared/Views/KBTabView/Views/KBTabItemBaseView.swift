//
//  Created by BK @kitabisa.
//

import UIKit

open class KBTabItemBaseView: UIView {
    
    public var isLoading: Bool = false
    
    private(set) var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let badgeContainer: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        return view
    }()
    
    private lazy var leftIconImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var leftPaddingConstraint: NSLayoutConstraint!
    private var rightPaddingConstraint: NSLayoutConstraint!
    
    var leftPadding: CGFloat = 4 {
        didSet {
            leftPaddingConstraint?.constant = leftPadding
        }
    }
    
    var rightPadding: CGFloat = 4 {
        didSet {
            rightPaddingConstraint?.constant = -rightPadding
        }
    }
    
    private let stackContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 6
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackContainer)
        stackContainer.addArrangedSubview(titleLabel)
        
        leftPaddingConstraint = stackContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
        rightPaddingConstraint = stackContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        
        NSLayoutConstraint.activate([
            stackContainer.topAnchor.constraint(equalTo: topAnchor),
            stackContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            leftPaddingConstraint,
            rightPaddingConstraint
        ])
        
        stackContainer.addArrangedSubview(badgeContainer)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        badgeContainer.layer.cornerRadius = badgeContainer.bounds.height / 2
    }
    
    func configureLabel(_ isLayoutFixed: Bool) {
        titleLabel.numberOfLines = isLayoutFixed ? 2 : 1
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.sizeToFit()
    }
    
    func configureBadgeView(_ isLayoutFixed: Bool, badgeValue: String?) {
        
        badgeContainer.removeAllArrangedSubviews()
        badgeContainer.removeFromSuperview()
        
        if let badgeValue, isLayoutFixed && !badgeValue.isEmpty {
            if badgeContainer.arrangedSubviews.isEmpty {
                
                let font = UIFont.systemFont(ofSize: 14, weight: .regular)
                let textSize = UILabel.textSize(font: font, text: badgeValue)
                
                let label = UILabel()
                label.backgroundColor = UIColor(hexString: "#3478F6")
                label.text = badgeValue.uppercased()
                label.font = font
                label.textColor = .white
                label.layer.cornerRadius = textSize.height / 2
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textAlignment = .center
                label.clipsToBounds = true
                label.layer.masksToBounds = true
                label.adjustsFontSizeToFitWidth = true
                
                badgeContainer.isHidden = badgeValue == "0"
                badgeContainer.addArrangedSubview(label)
                
                NSLayoutConstraint.activate([
                    label.widthAnchor.constraint(equalToConstant: textSize.width),
                    label.heightAnchor.constraint(equalToConstant: textSize.height)
                ])
                
                stackContainer.addArrangedSubview(badgeContainer)
            }
        }
    }
    
    func configureLeftIcon(model: LeftIconModel?) {
        guard let model = model else {
            leftIconImage.removeFromSuperview()
            return
        }
        stackContainer.insertArrangedSubview(leftIconImage, at: 0)
        leftIconImage.image = model.icon
        
//        if let url = model.url {
//            leftIconImage.resourceURL = url
//        } else {
//            leftIconImage.image = model.icon
//        }
        
        NSLayoutConstraint.activate([
            leftIconImage.heightAnchor.constraint(equalToConstant: model.size),
            leftIconImage.widthAnchor.constraint(equalToConstant: model.size)
        ])
    }
    
    func hideLeftIconWhenUnselected(_ isSelected: Bool) {
        leftIconImage.isHidden = isSelected == false
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Use init(frame:)")
    }
}

private extension UILabel {
    class func textSize(font: UIFont, text: String) -> (width: CGFloat, height: CGFloat) {
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        let width = ceil(labelSize.width)
        let height = ceil(labelSize.height)
    
        return (width < height ? height + 5 : width + 5, height + 5)
    }
}

private extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
