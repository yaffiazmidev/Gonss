import UIKit

final class TabItemView: UIView {
	
	var titleLabel: UILabel = UILabel()
	var counterLabel: UILabel = UILabel()
	public var textColor: UIColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
	public var counterColor: UIColor = UIColor(red: 0.906, green: 0.953, blue: 1, alpha: 1)
	public var selectedTextColor: UIColor = .white

    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, counterLabel])
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    
	lazy var view : UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.layer.borderColor = UIColor.secondary.cgColor
		view.layer.borderWidth = 1
		view.layer.cornerRadius = 8
        view.backgroundColor = .whiteSnow
		return view
	}()
	
	public var isSelected: Bool = false {
		didSet {
			if isSelected {
				titleLabel.textColor = selectedTextColor
				viewActive()
			} else {
				titleLabel.textColor = textColor
				viewDeactive()
			}
		}
	}
	
	func viewActive(){
		view.layer.borderColor = UIColor.secondary.cgColor
		view.layer.borderWidth = 1
		view.layer.cornerRadius = 8
        view.backgroundColor = .white
	}

	func viewDeactive(){
		view.layer.borderColor = UIColor.white.cgColor
		view.layer.borderWidth = 0
		view.layer.cornerRadius = 8
        view.backgroundColor = .whiteSnow
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupLabel()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override public func layoutSubviews() {
		super.layoutSubviews()
	}
	
	private func setupLabel() {
		addSubview(view)
		view.anchor(top: topAnchor, left: leftAnchor, bottom:  bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft:  5, paddingBottom: 5, paddingRight: 5)
		titleLabel = UILabel(frame: bounds)
		titleLabel.textAlignment = .center
		titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
		titleLabel.textColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
		titleLabel.backgroundColor = UIColor.clear
		
		counterLabel = UILabel(frame: .zero)
		counterLabel.translatesAutoresizingMaskIntoConstraints = false
		counterLabel.layer.masksToBounds = true
		counterLabel.layer.cornerRadius = 4
		counterLabel.textAlignment = .center
		counterLabel.font = UIFont.boldSystemFont(ofSize: 12)
        counterLabel.textColor = .secondary
		counterLabel.backgroundColor = counterColor
		counterLabel.text = "0"
		
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.fillSuperview(padding: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 6))
	}
	
	func setCounter(value: Int = 0) {
		counterLabel.isHidden = value == 0
		counterLabel.text = "\(value)"
	}
}
