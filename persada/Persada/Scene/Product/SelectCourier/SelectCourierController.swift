//
//  SelectCourierViewController.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 29/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

protocol SelectCourierDisplayLogic where Self: UIViewController {
    func displayViewModel(_ value: [CourierResult])
}

class SelectCourierController: UIViewController, AlertDisplayer {
    
    private let mainView: SelectCourierView
		private var refreshControl = UIRefreshControl()
	private let viewModel = SelectCourierViewModel()
    private let disposeBag = DisposeBag()
    private var dataCourier: [CourierResult] = []
    private let cellSpacingHeight: CGFloat = 16
    private let cellHeight: CGFloat = 60
    
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    required init(mainView: SelectCourierView) {
        self.mainView = mainView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindNavigationBar(String.get(.pilihKurir))
			
			viewModel.courierRelay.bind { (result) in
				self.dataCourier = result
				self.mainView.table.reloadData()
			}.disposed(by: disposeBag)
			
			viewModel.errorRelay.bind { (error) in
				if !error.isEmpty {
				 let action = UIAlertAction(title: "OK", style: .default)
						self.displayAlert(with: .get(.error), message: error, actions: [action])
				}
			}.disposed(by: disposeBag)
        
        viewModel.loadingRelay.bind { [weak self] isLoading in
            if isLoading {
                guard let view = self?.view else { return }
                self?.hud.show(in: view)
                return
            } else {
                self?.hud.dismiss()
            }
        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func loadView() {
        view = mainView
        view.backgroundColor = .white
			refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        mainView.table.register(SelectCourierTableViewCell.self, forCellReuseIdentifier: String.get(.cellID))
        mainView.table.delegate = self
        mainView.table.dataSource = self
        mainView.table.separatorStyle = .none
				mainView.table.refreshControl = refreshControl
        setupNav()
    }
	
	@objc
	func refresh(){
		refreshControl.endRefreshing()
	}
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    func setupNav(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:String.get(.arrowleft)), style: .plain, target: self, action: #selector(self.back))
    }
    
    @objc func back(){
			self.navigationController?.popViewController(animated: true)
    }
    // MARK: - ChannelSearchTopDisplayLogic
    func displayViewModel(_ value: [CourierResult]) {
        dataCourier = value
        mainView.table.reloadData()
    }
}

extension SelectCourierController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCourier.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.get(.cellID), for: indexPath) as! SelectCourierTableViewCell
        cell.setup()
        
        let courierStatus = dataCourier[indexPath.row].status ?? false
        let courierName = dataCourier[indexPath.row].logisticName
        var resourceName = ""
        switch courierName {
        case String.get(.anteraja):
            resourceName = String.get(.iconAnterAja)
        case String.get(.sicepat):
            resourceName = String.get(.iconSicepat)
        case String.get(.jnt):
            resourceName = String.get(.iconJNT)
        default:
            resourceName = String.get(.iconJNE)
        }
        cell.imageView?.image = UIImage(named: resourceName)
        cell.selectCourierImage.image = UIImage(named: String.get(courierStatus ? .iconCheckboxCheckedBlue: .iconUncheckRad4))
        cell.backgroundColor = courierStatus ? .orangeLowTint : .clear
        cell.layer.cornerRadius = 8
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
			let courierStatus = dataCourier[indexPath.row].status
			let courierID = dataCourier[indexPath.row].id
        
			if let status = courierStatus, let id = courierID {
				viewModel.updateCourier(id: id, isActive: !status, index: indexPath.row)
			}
        
    }
    
}

