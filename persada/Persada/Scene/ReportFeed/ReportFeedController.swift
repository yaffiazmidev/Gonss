//
//  ReportFeedController.swift
//  Persada
//
//  Created by Muhammad Noor on 19/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ReportFeedDelegate: AnyObject {
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
        table.estimatedRowHeight = 80
        table.backgroundColor = .clear
        table.isScrollEnabled = false
        table.register(ReportFeedCell.self, forCellReuseIdentifier: cellId)
        return table
    }()
    
    lazy var submitReportButton: UIButton = {
        let button = BadgedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.isUserInteractionEnabled = false
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = false
        button.backgroundColor = .whiteSmoke
        button.setTitleColor(.placeholder, for: .normal)
        button.titleLabel?.font = .Roboto(.bold, size: 14)
        button.addTarget(self, action: #selector(whenHandleTappedSubmitButton), for: .touchUpInside)
        button.setTitle("Lapor & Sembunyikan Postingan", for: .normal)
        return button
    }()
    
    
    lazy var reasonCTV: CustomTextView = {
        let ctv: CustomTextView = CustomTextView(backgroundColor: .white)
        ctv.placeholder = "Tulis alasan"
        ctv.nameLabel.font = .Roboto(.medium, size: 12)
        ctv.nameLabel.textColor = .grey
        ctv.nameTextField.backgroundColor = .whiteSnow
        ctv.nameTextField.layer.cornerRadius = 8
        ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
        ctv.nameTextField.layer.borderWidth = 1
        ctv.nameTextField.textContainerInset = UIEdgeInsets(horizontal: 12, vertical: 8)
        ctv.nameTextField.textStorage.delegate = self
        ctv.draw(.zero)
        return ctv
    }()
    
    var viewModel: ReportFeedViewModel?
    private var isAnotherReasonEmpty = true
    
    convenience init(viewModel: ReportFeedViewModel) {
        self.init()
        
        self.viewModel = viewModel
        bindViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindNavigationBar("Laporkan", true)
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        view.addSubview(submitReportButton)
        view.addSubview(reasonCTV)
        
        if #available(iOS 15.0, *) {
            tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingRight: 20, width: 0, height: 424)
        } else {
            tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingRight: 20, width: 0, height: 400)
        }
        
       
        
        reasonCTV.anchor(top: tableView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, height: 150)
        
        submitReportButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 50)
        
        reasonCTV.isHidden = true
        
        
//        let bott = submitReportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        bott.constant = -20
//        bott.priority = UILayoutPriority(220)
//        bott.isActive = true
        
        
        
        tableView.alwaysBounceVertical = false
        
        
        switch viewModel?.reportType {
        case .COMMENT:
            viewModel?.fetchReasonComment()
        case .COMMENT_SUB:
            viewModel?.fetchReasonSubcomment()
        default:
            viewModel?.fetchReason()
        }
        
        addBackButton()
        addGesture()
    }
    
    func addBackButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: AssetEnum.arrowleft.rawValue), style: .done, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    func addGesture() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(backGesture(gesture:)))
        gesture.direction = .right
        gesture.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
    }
    
    @objc
    func back() {
        addCustomDissmissAnimation()
        self.navigationController?.dismiss(animated: true)
    }
    
    @objc
    func backGesture(gesture: UISwipeGestureRecognizer) {
        addCustomDissmissAnimation()
        self.navigationController?.dismiss(animated: true)
    }
    
    func addCustomDissmissAnimation() {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        transition.type = .reveal
        transition.subtype = .fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
    }
    
    func setButtonActive() {
        submitReportButton.isUserInteractionEnabled = true
        submitReportButton.backgroundColor = .primary
        submitReportButton.setTitleColor(.white, for: .normal)
    }
    
    func setButtonInActive() {
        submitReportButton.isUserInteractionEnabled = false
        submitReportButton.backgroundColor = .whiteSmoke
        submitReportButton.setTitleColor(.placeholder, for: .normal)
    }
    
    
    @objc
    private func dismissVC() {
        dismiss(animated: true)
    }
    
    func bindViewModel() {
        
        viewModel?.changeHandler = { [weak self] change in
            
            guard let self = self else {
                return
            }
            
            switch change {
            case .didEncounterError(let error):
                print(error?.statusMessage ?? "")
                DispatchQueue.main.async {
                    self.displayAlert(with: .get(.error), message: error?.statusMessage ?? "unknown error", actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
                }
            case .didUpdateReason:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .didUpdateReport:
                DispatchQueue.main.async {
                    self.delegate?.reported()
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
    }
    
    @objc func whenHandleTappedSubmitButton() {
        
        guard let reasonId = viewModel?.reason.id, !reasonId.isEmpty else {
            return
        }
        
        if reasonCTV.isHidden {
            switch viewModel?.reportType {
            case .FEED, .COMMENT, .COMMENT_SUB:
                viewModel?.submitReportWithType()
            default:
                viewModel?.submitReport()
            }
        } else {
            viewModel?.reason.value = reasonCTV.nameTextField.text
            guard let reasonValue = viewModel?.reason.value, !reasonValue.isEmpty, reasonValue != "Tulis alasan" else {
                displayAlert(with: "Alasan lain" , message: "Silahkan tulis alasan kamu terlebih dahulu", actions: [UIAlertAction(title: "OK", style: .default)])
                return
            }
            viewModel?.submitReportWithType()
        }
    }
}

extension ReportFeedController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  viewModel?.totalCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReportFeedCell
        let reasonValueString = viewModel?.reason(at: indexPath.row).value
        cell.item = reasonValueString == "" ? "Alasan lainnya" : reasonValueString
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = ReportFeedHeaderView(frame: .zero)
        if viewModel?.reportType == ReportType.COMMENT {
            headerView.nameLabel.text = "Mengapa anda ingin melaporkan komentar ini?"
        }
        headerView.item = viewModel?.imageUrl
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let reason =  viewModel?.reason(at: indexPath.row) else {return}
        
        submitReportButton.isEnabled = reason.id?.isEmpty != true
        viewModel?.reason = reason
        viewModel?.type = viewModel?.reason(at: indexPath.row).type ?? ""
        //        tableView.cellForRow(at: indexPath)?.isSelected = true
        if reason.value == "" {
            reasonCTV.isHidden = false
            if isAnotherReasonEmpty {
                setButtonInActive()
            }
        } else {
            reasonCTV.isHidden = true
            setButtonActive()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension ReportFeedController: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        if textStorage.string.isEmpty || textStorage.string.contains("Tulis alasan") {
            isAnotherReasonEmpty = true
            return
        }
        
        if !textStorage.string.isEmpty {
            setButtonActive()
            isAnotherReasonEmpty = false
        }
    }
}


extension ReportFeedController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
