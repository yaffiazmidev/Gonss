import UIKit
import KipasKipasShared

class ShortcutListOfDiamondCell: UITableViewCell {
	
	private lazy var iconImage: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .center
		image.anchors.height.equal(20)
		image.anchors.width.equal(20)
		image.backgroundColor = .clear
		return image
	}()
	
	private lazy var titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(hexString: "#4A4A4A")
		label.font = .roboto(.medium, size: 14)
		
		return label
	}()
	
	private lazy var subtitleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(hexString: "#777777")
		label.numberOfLines = 0
		label.font = .roboto(.regular, size: 11)
		
		return label
	}()
	
	lazy var gotoImage: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .center
		image.image = UIImage(named: "iconNavigateNext")
		image.anchors.height.equal(20)
		image.anchors.width.equal(20)
		return image
	}()
	
	lazy var textStackView: UIStackView = {
		let view = UIStackView(arrangedSubviews: [titleLbl, subtitleLbl])
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 4
		return view
	}()

	lazy var containerStackView: UIStackView = {
		let view = UIStackView(arrangedSubviews: [iconImage, textStackView, gotoImage])
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .horizontal
		view.alignment = .top
		view.distribution = .fill
		view.spacing = 12
		return view
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.backgroundColor = .white
		UIFont.loadCustomFonts
		contentView.addSubview(containerStackView)
		
		containerStackView.anchors.top.equal(contentView.anchors.top, constant: 8)
		containerStackView.anchors.leading.equal(contentView.anchors.leading, constant: 12)
		containerStackView.anchors.bottom.equal(contentView.anchors.bottom, constant: -8)
		containerStackView.anchors.trailing.equal(contentView.anchors.trailing, constant: -12)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configuree(with index: Int) {
		if index == 0 {
			iconImage.image = UIImage(named: "iconMoneyTransfer")
			titleLbl.text = "Tarik Diamond"
			subtitleLbl.text = "Tukarkan diamond menjadi nominal uang yang langsung dikirim ke rekening milikmu."
		} else {
			iconImage.image = UIImage(named: "iconGem")
			titleLbl.text = "Atur Jumlah Diamond Diterima"
			subtitleLbl.text = "Atur berapa banyak diamond yang kamu terima ketika membalasa pesan berbayar."
		}
	}
}
