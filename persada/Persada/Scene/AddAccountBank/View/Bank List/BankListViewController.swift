//
//  BankListViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

class BankListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: TextField!
    
    let disposeBag = DisposeBag()
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    var viewModel: AddAccountBankViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupView()
        registerObserver()
        title = "Daftar Bank"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel?.fetchBankList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createRightViewImage()
    }
    
    func setupView() {
        tableView.register(UINib(nibName: "BankListTableViewCell", bundle: nil), forCellReuseIdentifier: "BankList")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 48
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
    
    func registerObserver() {
        viewModel?.isLoading.subscribe(onNext: { [weak self] isLoading in
            guard let isLoading = isLoading else { return }
            if isLoading {
                guard let view = self?.view else { return }
                self?.hud.show(in: view)
                return
            } else {
                self?.tableView.reloadData()
                self?.hud.dismiss()
            }
        }).disposed(by: disposeBag)
        
        searchTextField.rx.text
            .asObservable()
            .debounce(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { text in
                guard let text = text else { return }
                if text.isEmpty {
                    self.viewModel?.pages = 0
                    self.viewModel?.isSearch = false
                    self.viewModel?.fetchBankList()
                } else {
                    let query = text.replacingOccurrences(of: " ", with: "+")
                    self.viewModel?.isSearch = true
                    self.viewModel?.fetchBankListByQuery(query: query)
                }
            }).disposed(by: disposeBag)
    }
}

extension BankListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.bank.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BankList") as? BankListTableViewCell {
            
            guard viewModel?.bank.isEmpty == false else {
                return cell
            }
            
            guard let validNamaBank = viewModel?.bank[indexPath.row].namaBank else {
                return cell
            }
            
            cell.bankLabel.text = validNamaBank
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        guard let viewModel = viewModel else { return }
        if indexPath.row == viewModel.bank.count - 1 && viewModel.pages != (viewModel.totalPages ?? 0) - 1 && !viewModel.isSearch{
            viewModel.fetchBankList()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard viewModel?.bank.isEmpty == false else {
            return
        }
        
        guard let validBank = viewModel?.bank[indexPath.row] else {
            return
        }
        
        viewModel?.bankChoice.accept(validBank)
        
        self.navigationController?.popViewController(animated: true)
    }
}
