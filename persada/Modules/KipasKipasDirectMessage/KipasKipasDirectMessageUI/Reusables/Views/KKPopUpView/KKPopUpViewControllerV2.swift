import UIKit
import KipasKipasShared
import KipasKipasDirectMessage

class KKPopUpViewControllerV2: UIViewController {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var cancelButton: KKDefaultButton!
	@IBOutlet weak var actionButton: KKDefaultButton!
	@IBOutlet weak var headerImage: UIImageView!
	@IBOutlet weak var secondTextStackView: UIStackView!
	@IBOutlet weak var secondTitleLabel: UILabel!
	@IBOutlet weak var secondSubtitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var handleTapActionButton: (() -> Void)?
	var handleTapCancelButton: (() -> Void)?
	
	private var popUpTile: String
	private var message: String
	private var cancelButtonTitle: String
	private var actionButtonTitle: String
	private let isHiddenCancelButton: Bool
    private let isHiddenCloseButton: Bool
	
	override func viewDidLoad() {
			super.viewDidLoad()
			setupView()
	}
	
    init(title: String,
         message: String,
         isHiddenCancelButton: Bool = false,
         cancelButtonTitle: String = "Batalkan",
         actionButtonTitle: String = "OK",
         isHiddenCloseButton: Bool = false)
	{
        self.popUpTile = title
        self.message = message
        self.isHiddenCancelButton = isHiddenCancelButton
        self.cancelButtonTitle = cancelButtonTitle
        self.actionButtonTitle = actionButtonTitle
        self.isHiddenCloseButton = isHiddenCloseButton
        super.init(nibName: "KKPopUpViewControllerV2", bundle: SharedBundle.shared.bundle)
    }
	
	required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		UIFont.loadCustomFonts
        messageLabel.textColor = UIColor(hexString: "#777777")
        secondSubtitleLabel.textColor = UIColor(hexString: "#777777")
        secondTitleLabel.textColor = UIColor(hexString: "#1890FF")
        actionButton.backgroundColor = UIColor(hexString: "#FF4265")
			titleLabel.text = popUpTile
			messageLabel.text = message
			cancelButton.isHidden = isHiddenCancelButton
			cancelButton.setTitle(cancelButtonTitle, for: .normal)
			actionButton.setTitle(actionButtonTitle, for: .normal)
		messageLabel.anchors.bottom.equal(secondTextStackView.anchors.top, constant: -20)
		messageLabel.font = .roboto(.regular, size: 12)
		actionButton.titleLabel?.font = .Roboto(.bold, size: 14)
		cancelButton.titleLabel?.font = .Roboto(.bold, size: 14)
        closeButton.isHidden = isHiddenCloseButton
	}
	
	func configureSecondText(isHidden: Bool?, title: String?, subtitle: String?) {
		guard let isHidden = isHidden, let secondTitle = title, let secondSubtitle = subtitle  else {
			return
		}
	
		DispatchQueue.main.async {
			self.secondTextStackView.isHidden = isHidden
			self.secondTitleLabel.text = secondTitle
			self.secondSubtitleLabel.text = secondSubtitle
		}
	}
	
	func changeImage(name: String?) {
		guard let imageName = name else { return }
		
		DispatchQueue.main.async {
			self.headerImage.image = UIImage.set(imageName)
		}
	}
	
	@IBAction func didClickCancelButton(_ sender: Any) {
			dismiss(animated: true, completion: handleTapCancelButton)
	}
	
	@IBAction func didClickActionButton(_ sender: Any) {
			dismiss(animated: true, completion: handleTapActionButton)
	}
	
	@IBAction func didClickCloseButton(_ sender: Any) {
			dismiss(animated: true)
	}
}
