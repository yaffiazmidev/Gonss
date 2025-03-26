//
//  ReportFeedController.swift
//  Persada
//
//  Created by Muhammad Noor on 19/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ReportFeedDelegate: class {
    func reported()
}

private let cellId: String = "cellId"

class ReportFeedController: UIViewController, AlertDisplayer {
    
    weak var delegate: ReportFeedDelegate?

	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.delegate = self
		table.dataSource = self
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.rowHeight = UITableView.automaticDimension
		table.estimatedRowHeight = 300
		table.backgroundColor = .clear
		table.register(ReportFeedCell.self, forCellReuseIdentifier: cellId)
		return table
	}()

	lazy var submitReportButton: UIButton = {
		let button = BadgedButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 20
		button.layer.masksToBounds = false
		button.setTitleColor(UIColor.init(hexString: "#BC1C22"), for: .normal)
		button.backgroundColor = UIColor.init(hexString: "#FAFAFA")
		button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
		button.titleLabel?.textColor = .red
		button.addTarget(self, action: #selector(whenHandleTappedSubmitButton), for: .touchUpInside)
		button.setTitle("Report & Sembunyikan Postingan", for: .normal)
		return button
	}()


	lazy var reasonCTV: CustomTextView = {
		let ctv: CustomTextView = CustomTextView(backgroundColor: .white)
		ctv.placeholder = "Tuliskan Alasan anda..."
		ctv.nameLabel.font = .Roboto(.medium, size: 12)
		ctv.nameLabel.textColor = .grey
		ctv.nameTextField.backgroundColor = .whiteSnow
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1

		ctv.draw(.zero)
		return ctv
	}()

	var viewModel: ReportFeedViewModel?

	convenience init(viewModel: ReportFeedViewModel) {
		self.init()

		self.viewModel = viewModel
		bindViewModel()
		viewModel.fetchReason()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		tableView.separatorStyle = .none

		view.addSubview(submitReportButton)
		view.addSubview(reasonCTV)
		submitReportButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 24, paddingRight: 20, width: 0, height: 50)
		view.addSubview(tableView)
		tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 10, paddingRight: 20, width: 0, height: 0)
		
		reasonCTV.anchor(top: tableView.bottomAnchor, left: view.leftAnchor, bottom: submitReportButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 20, paddingRight: 12, height: 150)


		let bott = submitReportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		bott.constant = -20
		bott.priority = UILayoutPriority(220)
		bott.isActive = true



		tableView.estimatedRowHeight = 50
		tableView.alwaysBounceVertical = false
	}

	func bindViewModel() {

		viewModel?.changeHandler = { [weak self] change in

			guard let self = self else {
				return
			}

			switch change {
				case .didEncounterError(let error):
					print(error?.statusMessage ?? "")
				case .didUpdateReason:
					DispatchQueue.main.async {
						self.tableView.reloadData()
					}
				case .didUpdateReport:
					DispatchQueue.main.async {
                        self.delegate?.reported()
						self.dismiss(animated: true, completion: nil)
					}
			}

		}
	}

	@objc func whenHandleTappedSubmitButton() {
		if !(viewModel?.reason.id?.isEmpty ?? false) {
			viewModel?.submitReport()
		} else {
			let title = "Warning"
			let action = UIAlertAction(title: "OK", style: .default)
			displayAlert(with: title , message: "Please, select your reason", actions: [action])
		}

	}
}

extension ReportFeedController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return  viewModel?.totalCount ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReportFeedCell
        cell.selectionStyle = .none
		cell.item = viewModel?.reason(at: indexPath.row).value
        cell.layer.cornerRadius = 8
		return cell
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = ReportFeedHeaderView(frame: .zero)
		headerView.item = viewModel?.imageUrl

		return headerView
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		guard let reason =  viewModel?.reason(at: indexPath.row) else {return}

		viewModel?.reason = reason
		viewModel?.type = viewModel?.reason(at: indexPath.row).type ?? ""
//        tableView.cellForRow(at: indexPath)?.isSelected = true
	}


	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 100
	}

}


class ReportFeedHeaderView: UIView {

	var item: String? {
		didSet {
			bg.loadImage(at: item ?? "")
		}
	}

	private let bg: UIImageView = {
		let iv = UIImageView()
		iv.translatesAutoresizingMaskIntoConstraints = false
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 32.5
		return iv
	}()

	private var nameLabel: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.textAlignment = .center
		lbl.textColor = .contentGrey
		lbl.textAlignment = .left
		lbl.text = "Mengapa anda ingin melaporkan postingan ini?"
		lbl.font = UIFont.boldSystemFont(ofSize: 14)
		lbl.numberOfLines = 0
		return lbl
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)

		layer.masksToBounds = false
		layer.cornerRadius = 10
		backgroundColor = .init(hexString: "#FAFAFA")

		addSubview(bg)
		bg.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 65, height: 65)
		bg.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

		addSubview(nameLabel)
		nameLabel.anchor(top: nil, left: bg.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 20, width: 0, height: 65)
		nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

class ReportFeedCell: UITableViewCell {
    
    var item: String? {
        didSet {
            nameLabel.text = item
        }
    }
    
    private var nameLabel: UILabel = {
			let lbl = UILabel(font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        return lbl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 270, height: 0)
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomPadding: CGFloat = 10
        contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundColor = selected ? .secondaryLowTint : .clear
        nameLabel.textColor = selected ? .secondary : .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
