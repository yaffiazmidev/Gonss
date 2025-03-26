import UIKit
import KipasKipasShared

final class SucceedSetDiamondViewController: UIViewController {
	
	private lazy var titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .black
		label.textAlignment = .center
		label.numberOfLines = 0
		label.font = .roboto(.bold, size: 14)
		label.text = "Berhasil merubah jumlah diamond diterima"
		return label
	}()
	
	private lazy var subtitleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(hexString: "#777777")
		label.numberOfLines = 0
		label.textAlignment = .center
		label.font = .roboto(.regular, size: 11)
		label.text = "Perubahan ini akan langsung di terapkan di setiap pesan yang sedang berlangsung."
		return label
	}()
	
	lazy var iconDiamond: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .scaleAspectFit
		image.image = UIImage.set("ic_ok")
		image.anchors.height.equal(56)
		image.anchors.width.equal(56)
		return image
	}()
	
	lazy var okButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = UIColor(hexString: "#FF4265")
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .roboto(.bold, size: 14)
		button.layer.cornerRadius = 4
		button.isEnabled = false
				button.addTarget(self, action: #selector(dismissPopUp), for: .touchUpInside)
		button.setTitle("OK", for: .normal)
		return button
	}()
	
	lazy var containerStackView: UIStackView = {
		let view = UIStackView(arrangedSubviews: [iconDiamond, titleLbl, subtitleLbl, okButton])
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 12
		view.layer.cornerRadius = 10
		view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		view.isLayoutMarginsRelativeArrangement = true
		okButton.anchors.height.equal(42)
		return view
	}()
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		view.onTap { [weak self] in
			guard let self = self else { return }
			self.dismiss(animated: true)
		}
	}
	
	func setupUI() {
		view.backgroundColor = UIColor(white: 0, alpha: 0.5)
		view.addSubview(containerStackView)
		containerStackView.anchors.centerX.equal(view.anchors.centerX)
		containerStackView.anchors.centerY.equal(view.anchors.centerY)
		containerStackView.anchors.width.equal(230)
	}
	
	@objc func dismissPopUp() {
		self.dismiss(animated: true)
	}
}
