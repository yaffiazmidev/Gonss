//
//  ReportAccountController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

private let cellId: String = "cellId"

class ReportAccountController: UIViewController, AlertDisplayer {
    
//    weak var delegate: ReportFeedDelegate?
    var changeReportAccount: (() -> Void)?
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.allowsMultipleSelection = false
        table.isMultipleTouchEnabled = false
        table.tableFooterView = UIView()
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.backgroundColor = .clear
        table.isScrollEnabled = false
        table.register(ReportFeedCell.self, forCellReuseIdentifier: cellId)
        return table
    }()
    
    lazy var submitReportButton: UIButton = {
        let button = BadgedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = false
        button.setTitleColor(.contentGrey, for: .normal)
        button.backgroundColor = .whiteSnow
        button.titleLabel?.textColor = .contentGrey
        button.titleLabel?.font = .Roboto(.bold, size: 14)
        button.addTarget(self, action: #selector(whenHandleTappedSubmitButton), for: .touchUpInside)
        button.setTitle(.get(.reportAndHidePost), for: .normal)
        return button
    }()
    
    
    lazy var reasonCTV: CustomTextView = {
        let ctv: CustomTextView = CustomTextView(backgroundColor: .white)
        ctv.placeholder = .get(.writeReason)
        ctv.nameLabel.font = .Roboto(.medium, size: 12)
        ctv.nameLabel.textColor = .grey
        ctv.nameTextField.backgroundColor = .whiteSnow
        ctv.nameTextField.layer.cornerRadius = 8
        ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
        ctv.nameTextField.layer.borderWidth = 1
        ctv.nameTextField.textContainerInset = UIEdgeInsets(horizontal: 12, vertical: 16)
        ctv.draw(.zero)
        return ctv
    }()
    
    var viewModel: ReportAccountViewModel?
    
    convenience init(viewModel: ReportAccountViewModel) {
        self.init()
        
        self.viewModel = viewModel
        bindViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindNavigationBar("Laporkan", true)
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        view.addSubview(submitReportButton)
        view.addSubview(reasonCTV)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingRight: 20, width: 0, height: 424)
        
        reasonCTV.anchor(top: tableView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, height: 150)
        
        submitReportButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 50)
        
        reasonCTV.isHidden = true
        tableView.alwaysBounceVertical = false
        
        switch viewModel?.reportType {
        case .COMMENT, .COMMENT_SUB:
            viewModel?.fetchReasonComment()
        default:
            viewModel?.fetchReason()
        }
    }
    
    func bindViewModel() {
        
        viewModel?.changeHandler = { [weak self] change in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch change {
                case .didEncounterError(let error):
                    self.displayAlert(with: .get(.error), message: error?.statusMessage ?? "unknown error", actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
                case .didUpdateReason:
                        self.tableView.reloadData()
                case .didUpdateReport:
                    self.changeReportAccount?()
                }
            }
        }
    }
    
    @objc func whenHandleTappedSubmitButton() {
        if !(viewModel?.reason.id?.isEmpty ?? false) {
            if let _ = viewModel?.reason.value?.isEmpty {
                viewModel?.reason.value = reasonCTV.nameTextField.text
                switch viewModel?.reportType {
                case .FEED, .COMMENT, .COMMENT_SUB:
                    viewModel?.submitReportWithType()
                default:
                    viewModel?.submitReport()
                }
                return
            }
            viewModel?.submitReport()
        } else {
            let title = "Warning!"
            let action = UIAlertAction(title: .get(.ok), style: .default)
            displayAlert(with: title , message: .get(.pleaseSelectYourReason), actions: [action])
        }
        
    }
}

extension ReportAccountController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.totalCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReportFeedCell
        let reasonValueString = viewModel?.reason(at: indexPath.row).value
        cell.item = reasonValueString == "" ? .get(.otherReason) : reasonValueString
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = ReportFeedHeaderView(frame: .zero)
        if viewModel?.reportType == ReportType.COMMENT {
            headerView.nameLabel.text = .get(.askingReportAccount)
        }
        headerView.item = viewModel?.imageUrl
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let reason =  viewModel?.reason(at: indexPath.row) else {return}
        
        viewModel?.reason = reason
        viewModel?.type = viewModel?.reason(at: indexPath.row).type ?? ""
        reasonCTV.isHidden = reason.value == "" ? false : true
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
