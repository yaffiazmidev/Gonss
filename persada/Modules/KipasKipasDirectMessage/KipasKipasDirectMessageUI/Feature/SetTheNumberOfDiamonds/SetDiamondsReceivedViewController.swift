import UIKit
import KipasKipasShared
import KipasKipasDirectMessage

public class SetDiamondsReceivedViewController: UIViewController, NavigationAppearance {

	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.separatorStyle = .none
		table.showsVerticalScrollIndicator = false
		table.isScrollEnabled = false
		table.layer.cornerRadius = 10
		table.delegate = self
		table.dataSource = self
		table.rowHeight = UITableView.automaticDimension
		table.estimatedRowHeight = UITableView.automaticDimension
		table.registerNib(MessageTableViewCell.self)
		table.backgroundColor = .clear
		return table
	}()
	
	private lazy var titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(hexString: "#4A4A4A")
		label.font = .roboto(.regular, size: 11)
		label.text = "Jumlah Diamond Diterima"
		return label
	}()
	
	
	private lazy var warningLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(hexString: "#4A4A4A")
		label.font = .roboto(.regular, size: 14)
		label.numberOfLines = 0
		label.text = "Kamu bisa melakukan perubahan \(self.dayBetweenDates) hari setelah terakhir kali melakukan perubahan jumlah diamond."
		return label
	}()
	
	private lazy var subtitleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(hexString: "#777777")
		label.numberOfLines = 0
		label.font = .roboto(.regular, size: 14)
		label.text = "Jumlah yang dimasukan disini akan diterima setiap penggemarmu mengirimkan pesan, kemudian kamu membalas pesannya."
		return label
	}()
	
	private lazy var priceLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(hexString: "#BBBBBB")
		label.numberOfLines = 0
		label.font = .roboto(.regular, size: 14)
		label.text = "RP 30.000,00"
		return label
	}()
	
	lazy var iconDiamond: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .scaleAspectFit
		image.image = UIImage.set("img_diamond_blue")
		image.anchors.height.equal(20)
		image.anchors.width.equal(20)
		return image
	}()
	
	lazy var setDiamondsButton: UIButton = {
		let button = UIButton()
		button.backgroundColor = UIColor(hexString: "#FFA4B5")
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .roboto(.bold, size: 14)
		button.layer.cornerRadius = 4
		button.isEnabled = false
		button.addTarget(self, action: #selector(handleSetDiamond), for: .touchUpInside)
		button.setTitle("Terapkan Jumlah Diamond Diterima", for: .normal)
			return button
	}()
	
	lazy var inputDiamondTextField: UITextField = {
		let txt = UITextField()
		txt.font = .roboto(.regular, size: 14)
		txt.keyboardType = .numberPad
		txt.textColor = .black
		txt.text = "1"
		return txt
	}()
	
	lazy var textStackView: UIStackView = {
		let stkView = UIStackView(arrangedSubviews: [iconDiamond, inputDiamondTextField, priceLbl])
		stkView.translatesAutoresizingMaskIntoConstraints = false
		stkView.axis = .horizontal
		stkView.alignment = .fill
		stkView.distribution = .fill
		stkView.spacing = 4
		stkView.layer.cornerRadius = 6
		stkView.layer.borderColor = UIColor.systemBlue.cgColor
		stkView.layer.borderWidth = 1
		iconDiamond.anchors.height.equal(20)
		iconDiamond.anchors.width.equal(20)
		iconDiamond.anchors.leading.equal(stkView.anchors.leading, constant: 12)
		priceLbl.anchors.trailing.equal(stkView.anchors.trailing)
		priceLbl.anchors.top.equal(stkView.anchors.top)
		priceLbl.anchors.bottom.equal(stkView.anchors.bottom)
		priceLbl.anchors.width.equal(90)
		stkView.anchors.height.equal(45)
		return stkView
	}()

	lazy var containerStackView: UIStackView = {
		let view = UIStackView(arrangedSubviews: [titleLbl, textStackView, subtitleLbl, setDiamondsButton])
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 12
		view.layer.cornerRadius = 10
		view.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
		view.isLayoutMarginsRelativeArrangement = true
		setDiamondsButton.anchors.height.equal(42)
		return view
	}()
	
	
	lazy var warningStackView: UIStackView = {
		let view = UIStackView(arrangedSubviews: [warningLbl])
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		view.axis = .vertical
		view.alignment = .leading
		view.distribution = .fill
		view.layer.cornerRadius = 10
		view.isHidden = true
		view.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
		view.isLayoutMarginsRelativeArrangement = true
		return view
	}()
	
	private let delegate: SetDiamondDelegate
	private let accountId: String
	private var diamond: Int = 1
	private var price: Int = 0
	private var dayBetweenDates: Int = 0
    private let maxSetDiamond: Int = 10_000
	
	init(delegate: SetDiamondDelegate, accountId: String) {
		self.delegate = delegate
		self.accountId = accountId
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		UIFont.loadCustomFonts
		delegate.didReqeustLastDiamond()
		setupTableView()
		setupUIDiamond()
		handleInputDiamondTextField()
		setupNavigationBar(title: "Atur Jumlah Diamond Diterima", color: UIColor(hexString: "#F9F9F9"), tintColor: .black)
	}

	func setupTableView() {
		view.backgroundColor = UIColor(hexString: "#F9F9F9")
		view.addSubview(tableView)
		
		tableView.anchors.top.equal(view.safeAreaLayoutGuide.anchors.top, constant: 20)
		tableView.anchors.leading.equal(view.anchors.leading, constant: 12)
		tableView.anchors.trailing.equal(view.anchors.trailing, constant: -12)
		tableView.anchors.height.equal(140)
	}
	
	private func handleInputDiamondTextField() {
			inputDiamondTextField.delegate = self
			inputDiamondTextField.addTarget(self, action: #selector(didEditingChanged(_:)), for: .editingChanged)
	}
	func setupUIDiamond() {
		view.addSubview(containerStackView)
		containerStackView.anchors.top.equal(tableView.anchors.bottom, constant: 12)
		containerStackView.anchors.leading.equal(view.anchors.leading, constant: 12)
		containerStackView.anchors.trailing.equal(view.anchors.trailing, constant: -12)
		
		view.addSubview(warningStackView)
		warningStackView.anchors.top.equal(containerStackView.anchors.bottom, constant: 8)
		warningStackView.anchors.leading.equal(view.anchors.leading, constant: 12)
		warningStackView.anchors.trailing.equal(view.anchors.trailing, constant: -12)
		warningStackView.anchors.height.equal(60)
	}
	
	@objc func didEditingChanged(_ textField: UITextField) {
			
		guard let myDiamond = Int(textField.text ?? "") else {
			return
		}
		
		priceLbl.text = (myDiamond * self.price).toCurrency()
		if myDiamond > maxSetDiamond {
			setDiamondsButton.isEnabled = false
			setDiamondsButton.backgroundColor = UIColor(hexString: "#FFA4B5")
		} else {
			setDiamondsButton.isEnabled = true
			setDiamondsButton.backgroundColor = UIColor(hexString: "#FF4265")
		}
	}
	
	@objc func handleSetDiamond() {
		presentKKPopUpViewCustomImage(
			title: "Terapkan Perubahan Jumlah Diamond", 
			message: "Perubahan yang kamu terapkan akan mempengaruhi pesan berbayar yang sedang berjalan, dan kamu tidak akan bisa merubah lagi jumlah diamond dalam kurun waktu 30 Hari kedepan.",
			cancelButtonTitle: "Batal",
			actionButtonTitle: "Ya, terapkan sekarang",
			imageName: "img_diamond_blue") { [weak self] in
				guard let self = self else { return }
				
				guard let chatPrice = Int(self.inputDiamondTextField.text ?? "\(self.diamond)") else { return }
				self.delegate.didRequestSetDiamondsReceiveds(request: SetDiamondsReceivedRequest(chatPrice: chatPrice))
			}
	}
	
	func getDateDiff(start: Date, end: Date) -> Int  {
		let calendar = Calendar.current
		let dateComponents = calendar.dateComponents([Calendar.Component.day], from: start, to: end)
		
		let days = dateComponents.day
		return Int(days!)
	}
}

extension SetDiamondsReceivedViewController: UITableViewDelegate, UITableViewDataSource {
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: MessageTableViewCell = tableView.dequeueReusableCell(for: indexPath)
		cell.containerStackView.backgroundColor = .clear
		cell.messageLabel.font = .roboto(.regular, size: 14)
		if indexPath.row == 0 {
			cell.containerStackView.layoutMargins = .init(top: 0, left: 0, bottom: 0, right: 90)
			cell.containerStackView.alignment = .leading
			cell.messageComponentStackView.alignment = .fill
			cell.messageLabel.text = "kak nata gimana kabarnya?"
			cell.messageComponentStackView.backgroundColor = .white
			cell.messageSendingdateLabel.text = "11:13"
			cell.messageComponentStackView.dropShadow(scale: true)
		} else {
			cell.containerStackView.alignment = .trailing
			cell.containerStackView.layoutMargins = .init(top: 0, left: 90, bottom: 0, right: 0)
			cell.messageComponentStackView.alignment = .fill
			cell.increaseDiamondContainerStackView.isHidden = false
			cell.messageLabel.text = "Sehat dong, Kalo kamu ???? 😁"
			cell.diamondPriceLabel.text = "+\(diamond)"
			cell.messageComponentStackView.backgroundColor = UIColor(hexString: "#E1FED3")
			cell.messageSendingdateLabel.text = "11:16"
			cell.messageStatusIconImageView.isHidden = false
			cell.messageStatusIconImageView.image = UIImage.set("ic_check_double_blue")
			cell.messageComponentStackView.dropShadow(scale: true)
		}
		return cell
	}
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
}

extension SetDiamondsReceivedViewController: UITextFieldDelegate {
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if range.location == 0 && string == "0" {
			return false
		}
		
		let maxLength = 5
		guard let text = textField.text else { return true }
		let newLength = text.count + string.count - range.length
		
		return newLength <= maxLength
	}
}

extension SetDiamondsReceivedViewController: LastDiamondView, LastDiamondLoadingView, LastDiamondLoadingErrorView {
	func display(_ viewModel: LastDiamondViewModel) {
		DispatchQueue.main.async { [self] in
			self.inputDiamondTextField.text = "\(viewModel.item.lastSetDiamond)"
			self.priceLbl.text = viewModel.item.conversionCurrency.toCurrency()
			self.diamond = viewModel.item.lastSetDiamond
			let milisecond = Int64(Date().timeIntervalSince1970 * 1_000)
			let allowAt = Date(timeIntervalSince1970: TimeInterval(viewModel.item.allowChangeAt / 1000))
			let now = Calendar.current.startOfDay(for: Date())
			self.price = viewModel.item.conversionCurrency
			if viewModel.item.allowChangeAt > milisecond {
				self.warningStackView.isHidden = false
				self.setDiamondsButton.isHidden = true
				
				self.dayBetweenDates = self.getDateDiff(start: now, end: allowAt)
				self.warningLbl.text = "Kamu bisa melakukan perubahan \(self.dayBetweenDates) hari setelah terakhir kali melakukan perubahan jumlah diamond."
				self.view.layoutIfNeeded()
			} else {
				self.warningStackView.isHidden = true
				self.setDiamondsButton.isHidden = false
			}
			self.tableView.reloadData()
		}
	}
	
	func display(_ viewModel: LastDiamondLoadingViewModel) {
		
	}
	
	func display(_ viewModel: LastDiamondLoadingErrorViewModel) {
		DispatchQueue.main.async {
            if viewModel.message != nil {
                let vc = FailedSetDiamondViewController()
                vc.hidesBottomBarWhenPushed = true
                self.present(vc, animated: true)
            }
		}
	}
}

extension SetDiamondsReceivedViewController: SetDiamondsReceivedView, SetDiamondsReceivedLoadingView, SetDiamondsReceivedLoadingErrorView {
	func display(_ viewModel: SetDiamondsReceivedViewModel) {
		DispatchQueue.main.async {
			let vc = SucceedSetDiamondViewController()
			vc.hidesBottomBarWhenPushed = true
			self.present(vc, animated: true)
			self.warningStackView.isHidden = false
			self.setDiamondsButton.isHidden = true
			self.dayBetweenDates = 30
			self.warningLbl.text = "Kamu bisa melakukan perubahan \(self.dayBetweenDates) hari setelah terakhir kali melakukan perubahan jumlah diamond."
			guard let myDiamond = Int(self.inputDiamondTextField.text ?? "0") else { return }
			self.diamond = myDiamond
			self.tableView.reloadData()
		}
	}
	
	func display(_ viewModel: SetDiamondsReceivedLoadingViewModel) {
		
	}
	
	func display(_ viewModel: SetDiamondsReceivedLoadingErrorViewModel) {
		DispatchQueue.main.async {
            if viewModel.message != nil {
                let vc = FailedSetDiamondViewController()
                vc.hidesBottomBarWhenPushed = true
                self.present(vc, animated: true)
            }
		}
	}
}
