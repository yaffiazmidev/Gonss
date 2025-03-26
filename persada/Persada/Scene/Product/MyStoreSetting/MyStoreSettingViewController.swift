//
//  MyStoreSettingViewController.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 18/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MyStoreSettingDisplayLogic where Self: UIViewController {
}

class MyStoreSettingViewController: UIViewController,Displayable,AlertDisplayer,MyStoreSettingDisplayLogic {
	
	private let mainView: MyStoreSettingView
	private var interactor: MyStoreSettingInteractable!
	private var router: MyStoreSettingRouting!
	private var presenter: MyStoreSettingPresenter!
	private var menus: [MyStoreSetting]!
	private var addressAdded = true
	private let disposeBag = DisposeBag()
	
	private var settingData = MyStoreSettingData.fetchMyStoreSettingData()

	required init(mainView: MyStoreSettingView, dataSource: MyStoreSettingModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = MyStoreSettingInteractor(viewController: self, dataSource: dataSource)
		router = MyStoreSettingRouter(self)
		presenter = MyStoreSettingPresenter(self)
		menus = interactor.dataSource.items
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		bindNavigationBar(String.get(.myStoreSetting))
		createObservers()
        
        presenter.productsRelay.bind { (products) in
            self.settingData[1].isDisable = products.count <= 0
            self.settingData[2].isDisable = products.count <= 0
            DispatchQueue.main.async {
                self.mainView.table.reloadData()
            }
        }.disposed(by: disposeBag)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tabBarController?.tabBar.isHidden = true
		navigationController?.setNavigationBarHidden(false, animated: false)
		
		getAddressState()
        
	}
	
	func getAddressState(){
		presenter.fetchAddressDelivery {
			
				self.addressAdded = true
			DispatchQueue.main.async {
				
                self.presenter.fetchProducts()
                    self.mainView.table.reloadData()
			}
		} addressNotFound: {
			self.addressAdded = false
				self.settingData[1].isDisable = true
				self.settingData[2].isDisable = true
			
		DispatchQueue.main.async {
			
            self.presenter.fetchProducts()
                self.mainView.table.reloadData()
		}
            
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func createObservers(){
		NotificationCenter.default.addObserver(self, selector: #selector(showDialogAddKurir), name: kurirNotificationKey, object: nil)
	}
	
	@objc
	func showDialogAddKurir(){
		showDialog(title: .get(.alamatBerhasilDirubah), desc: .get(.alamatBerhasilDirubahDesc))
	}
	
	func showDialog(title: String, desc: String){
			let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
			alert.overrideUserInterfaceStyle = .light
			alert.addAction(UIAlertAction(title: .get(.pilihUlangKurir), style: .default, handler: { action in
				alert.dismiss(animated: true, completion: {
					self.router.routeTo(.showMyCourier)
				})
			}))
		alert.addAction(UIAlertAction(title: .get(.lewati), style: .destructive, handler: { action in
				alert.dismiss(animated: true, completion: nil)
		}))
			self.present(alert, animated: true, completion: nil)
	}
	
	override func loadView() {
		view = mainView
		view.backgroundColor = .white
		mainView.table.register(MyStoreSettingTableViewCell.self, forCellReuseIdentifier: String.get(.cellID))
		mainView.table.delegate = self
		mainView.table.dataSource = self
		mainView.table.separatorStyle = .none
		setupNav()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	func setupNav(){
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:String.get(.arrowleft)), style: .plain, target: self, action: #selector(self.back))
	}
	
	@objc func back(){
		router.routeTo(.dismissMyStoreSetting)
	}
	
	
}

extension MyStoreSettingViewController : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String.get(.cellID), for: indexPath) as! MyStoreSettingTableViewCell
		cell.setup()
		
		let data = settingData[indexPath.row]
		cell.title.text = data.title
		cell.imageView?.image = data.image
		if data.isDisable {
			cell.title.textColor = .grey
			cell.isUserInteractionEnabled = false
		} else {
				cell.title.textColor = .black
				cell.isUserInteractionEnabled = true
		}

		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch indexPath.row {
		case 0:
            router.routeTo(.showMyAddress)
		case 1:
			router.routeTo(.showMyCourier)
		case 2:
			router.routeTo(.showMyArchiveProduct)
		default:
			break
		}
	}
	
}
