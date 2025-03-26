//
//  HistoryTransactionsViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 20/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import KipasKipasShared

class HistoryTransactionsViewController: UIViewController, AlertDisplayer {

    @IBOutlet weak var searchStackView: UIStackView!
    @IBOutlet weak var resetFilterStackView: UIStackView!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var searchTextField: TextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var resetFilterView: UIView!
    @IBOutlet weak var resetFilterButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notFoundStackView: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    var disposeBag = DisposeBag()
    var viewModel = HistoryTransactionsViewModel()
    var isUserSearching = false {
        didSet {
            setupViewByTextField()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Riwayat Transaksi"
        setupTableView()
        setupNavbar()
        registerObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createRightViewImage()
        viewModel.isFilterData.value ? viewModel.fetchByFilter() : viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavbar()
    }
    
    func registerObserver() {
        searchTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .subscribe(onNext: { [weak self] in
                self?.isUserSearching = !self!.isUserSearching
            }).disposed(by: disposeBag)
        
        viewModel.dataManipulation.bind(to: historyTableView.rx.items) { tableView, index, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryTransactionTableViewCell
            cell.data = item
            return cell
        }.disposed(by: disposeBag)
        
        viewModel.dataManipulation.subscribe(onNext: { [weak self] data in
            self?.setupViewSearch(data: data)
        }).disposed(by: disposeBag)
        
        searchTextField.rx.text.throttle(.microseconds(1500), latest: true, scheduler: MainScheduler.instance).distinctUntilChanged()
            .subscribe(onNext: { text in
                self.viewModel.query.accept(text)
                self.viewModel.fetchBySearch()
            }).disposed(by: disposeBag)
        
        viewModel.isFilterData.subscribe(onNext: { [weak self] filter in
            self?.setupResetFilterButton(filter: filter)
        }).disposed(by: disposeBag)
        
        viewModel.isLoading.subscribe(onNext: { [weak self] isLoading in
            if isLoading {
                guard let view = self?.view else { return }
                self?.hud.show(in: view)
                return
            }
            self?.hud.dismiss()
        }).disposed(by: disposeBag)
        
        viewModel.errorMessage.subscribe(onNext: { [weak self] message in
            guard let message = message else { return }
            if !message.isEmpty {
                self?.setupAlert(message: message)
            }
        }).disposed(by: disposeBag)
        
        historyTableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                if let orderId = self.viewModel.dataManipulation.value[indexPath.row].orderId {
                    print(orderId)
                    let type = self.viewModel.dataManipulation.value[indexPath.row].activityType
                    self.routeToDetail(id: orderId, type: type)
                } else {
                    self.routeToWithdrawalSuccess(model: self.viewModel.dataManipulation.value[indexPath.row])
                }
            }).disposed(by: disposeBag)
    }
    
    func navigateToFilterView() {
        let viewController = FilterViewController()
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        viewController.passData = { [weak self] dateFrom, dateTo, type in
            self?.viewModel.dateFrom.accept(dateFrom)
            self?.viewModel.dateTo.accept(dateTo)
            self?.viewModel.transactionType.accept(type.rawValue)
            self?.viewModel.fetchByFilter()
            self?.viewModel.isFilterData.accept(true)
        }
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    func setupAlert(message: String) {
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: .get(.error), message: message, actions: [action])
    }
    
    func setupTableView() {
        historyTableView.register(UINib(nibName: "HistoryTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        historyTableView.tableFooterView = UIView(frame: .zero)
        historyTableView.separatorColor = UIColor.clear
        historyTableView.rowHeight = 40
    }
    
    func setupViewSearch(data: [HistoryTransactionModel]) {
        if data.isEmpty && isUserSearching {
            notFoundStackView.alpha = 1
            historyTableView.alpha = 0
            titleStackView.alpha = 0
            resetFilterView.isHidden = true
            resetFilterButtonHeightConstraint.constant = 0
        } else if !data.isEmpty && isUserSearching {
            notFoundStackView.alpha = 0
            historyTableView.alpha = 1
            titleStackView.alpha = 1
            viewModel.isFilterData.value ? setupResetFilterButton(filter: viewModel.isFilterData.value) : setupResetFilterButton(filter: viewModel.isFilterData.value)
        } else {
            notFoundStackView.alpha = 0
            historyTableView.alpha = 1
            titleStackView.alpha = 1
        }
    }
    
    func setupViewByTextField() {
        if isUserSearching {
            historyTableView.alpha = 0
            titleStackView.alpha = 0
            resetFilterView.isHidden = true
            cancelButton.isHidden = !isUserSearching
            filterButton.isHidden = isUserSearching
        } else {
            searchTextField.text = ""
            historyTableView.alpha = 1
            titleStackView.alpha = 1
            !viewModel.isFilterData.value ? viewModel.fetchData() : setupResetFilterButton(filter: viewModel.isFilterData.value)
            cancelButton.isHidden = !isUserSearching
            filterButton.isHidden = isUserSearching
            viewModel.isFilterData.value ? viewModel.fetchByFilter() : viewModel.fetchData()
        }
    }
    
    func setupResetFilterButton(filter: Bool) {
        if filter {
            resetFilterView.isHidden = !filter
            resetFilterButtonHeightConstraint.constant = 40
        } else {
            resetFilterView.isHidden = !filter
            resetFilterButtonHeightConstraint.constant = 0
        }
    }
    
    func createRightViewImage() {
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = UIColor(hexString: "BBBBBB")
        imageView.center = rightView.center
        rightView.addSubview(imageView)
        
        searchTextField.rightView = rightView
        searchTextField.rightViewMode = .always
    }
    
    func routeToDetail(id: String, type: String) {
        let vc = DetailHistoryViewController()
        vc.viewModel.orderId = id
        if type == "TRANSACTION" || type == "COMMISSION" || type == "MODAL" {
            vc.viewModel.type = .transaction
        } else {
            vc.viewModel.type = .refund
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func routeToWithdrawalSuccess(model: HistoryTransactionModel) {
        let vc = SuccessWithdrawalViewController()
        vc.from = self
        vc.model = model
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        navigateToFilterView()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        isUserSearching = false
        view.endEditing(true)
    }
    
    @IBAction func resetFilterPressed(_ sender: Any) {
        viewModel.isFilterData.accept(false)
        viewModel.fetchData()
    }
}
