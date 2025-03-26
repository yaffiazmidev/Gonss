import UIKit
import KipasKipasShared
import KipasKipasDirectMessage

class ShortcutListOfDiamondViewController: UIViewController, NavigationAppearance {

	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.separatorStyle = .none
		table.backgroundColor = .white
		table.showsVerticalScrollIndicator = false
		table.layer.cornerRadius = 10
		table.delegate = self
		table.dataSource = self
		table.rowHeight = UITableView.automaticDimension
		table.estimatedRowHeight = UITableView.automaticDimension
		table.register(ShortcutListOfDiamondCell.self, forCellReuseIdentifier: "cellId")
		return table
	}()

	private lazy var titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(hexString: "#777777")
		label.font = .roboto(.regular, size: 11)
		label.text = "Pengaturan"
		return label
	}()
	
	private let baseUrl: String
	private let authToken: String
	private let diamond: Int
	private var showListBank: ((@escaping (BankAccountItem) -> Void) -> Void)?
    private var showVerifyIdentity: ((String) -> Void)?
	
	init(diamond: Int, baseUrl: String, authToken: String, showListBank: ((@escaping (BankAccountItem) -> Void) -> Void)?) {
		self.diamond = diamond
		self.authToken = authToken
		self.baseUrl = baseUrl
		self.showListBank = showListBank
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationBar(title: "Diamond", color: UIColor(hexString: "#F9F9F9"), tintColor: .black)
		setupTableView()
	}
	
	private func setupTableView() {
		view.backgroundColor = UIColor(hexString: "#F9F9F9")
		view.addSubview(titleLbl)
		view.addSubview(tableView)
		
		titleLbl.anchors.top.equal(view.safeAreaLayoutGuide.anchors.top, constant: 20)
		titleLbl.anchors.leading.equal(view.anchors.leading, constant: 24)
		titleLbl.anchors.trailing.equal(view.anchors.trailing)
		titleLbl.anchors.height.equal(13)
		
		tableView.anchors.top.equal(titleLbl.anchors.bottom, constant: 8)
		tableView.anchors.leading.equal(view.anchors.leading, constant: 12)
		tableView.anchors.trailing.equal(view.anchors.trailing, constant: -12)
		tableView.anchors.height.equal(140)
	}
}

extension ShortcutListOfDiamondViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ShortcutListOfDiamondCell
		cell.configuree(with: indexPath.row)
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.row == 0 {
			let vc = DiamondWithdrawalRouter.create(
//				diamond: diamond,
                type:"DM",
				baseUrl: baseUrl,
				authToken: authToken,
                showListBank: showListBank, 
                showVerifyIdentity: showVerifyIdentity
			)
			vc.hidesBottomBarWhenPushed = true
			self.push(vc)
		} else {
			guard let userId = UserConnectionUseCase.shared.userId, !userId.isEmpty else {
					presentAlert(title: "Error", message: "User cached not found..")
					return
			}
			let vc = SetDiamondsReceivedUIFactory.create(accountId: userId)
			vc.hidesBottomBarWhenPushed = true
			vc.bindNavBar()
			self.push(vc)
		}
	}
}
