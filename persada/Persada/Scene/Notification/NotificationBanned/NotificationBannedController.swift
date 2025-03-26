//
//  NotificationBannedController.swift
//  KipasKipas
//
//  Created by koanba on 08/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

class NotificationBannedController: UIViewController, UIGestureRecognizerDelegate {

    private let mainView: NotificationBannedView
    private let interactor: NotificationBannedInteractor
    
    private let disposeBag = DisposeBag()
    var isLoading = BehaviorRelay<Bool?>(value: nil)
    
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    var id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(mainView: NotificationBannedView, id: String) {
        // 2c94812e76036174017607acdceb01f9
        self.id = id
        self.mainView = mainView
        self.interactor = NotificationBannedInteractor()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
        mainView.initView()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.hideKeyboardWhenTappedAround()
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupObservers() {
        if let id = self.id {
            self.isLoading.accept(true)
            interactor.detailNotificationTransaction(id: id)
                .subscribe { [weak self] result in
                    if let product = result.data {
                        self?.mainView.setupView(product: product)
                    }
                    self?.isLoading.accept(false)
                } onError: { [weak self] error in
                    self?.mappingErrorRelay(error: error)
                    self?.isLoading.accept(false)
                }.disposed(by: disposeBag)
        }
        
        self.isLoading.subscribe(onNext: { [weak self] isLoading in
            guard let isLoading = isLoading else { return }
            if isLoading {
                guard let view = self?.view else { return }
                self?.hud.show(in: view)
                return
            } else {
                self?.hud.dismiss()
            }
        }).disposed(by: disposeBag)
    }
    
    func mappingErrorRelay(error: Error) {
        if let apiError = error as? ErrorMessage {
            self.showDialog(title: .get(.error), desc: apiError.statusData ?? .get(.errorUnknown))
        } else {
            self.showDialog(title: .get(.error), desc: error.localizedDescription)
        }
    }
    
    func showDialog(title: String, desc: String){
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .get(.ok), style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
