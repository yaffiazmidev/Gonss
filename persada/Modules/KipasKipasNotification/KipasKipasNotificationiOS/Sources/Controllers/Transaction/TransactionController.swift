//
//  TransactionController.swift
//  KipasKipasNotificationiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/03/24.
//

import UIKit
import KipasKipasShared
import KipasKipasNotification

public class TransactionController: UIViewController {
    
    private let mainView: TransactionView
    private let loader: NotificationTransactionLoader
    private let readUpdater: NotificationReadUpdater
    var router: ITransactionRouter?
    
    var page: Int
    var isLoading: Bool
    
    public init(
        loader: NotificationTransactionLoader,
        readUpdater: NotificationReadUpdater
    ) {
        mainView = TransactionView()
        self.loader = loader
        self.readUpdater = readUpdater
        page = 0
        isLoading = false
        super.init(nibName: nil, bundle: nil)
        mainView.delegate = self
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view = mainView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupNavigationBar()
        load(reset: true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        readNotif()
    }
}

// MARK: Private Helper
private extension TransactionController {
    func setupNavigationBar() {
        navigationItem.title = "Transaksi"
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = .black
        
        let leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed)
        )
        
        let rightBarButtonItem = UIBarButtonItem(
            image: .iconGearThin,
            style: .plain,
            target: self,
            action: #selector(settingButtonPressed)
        )
        
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func backButtonPressed() {
        popViewController()
    }
    
    @objc func settingButtonPressed() {
        let controller = TransactionSettingController()
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: false)
    }
}

// MARK: - Data Logic
private extension TransactionController {
    func load(reset: Bool) {
        guard !isLoading else { return }
        
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            mainView.stopLoading()
            
//            if mainView.data.isEmpty {
                mainView.setNoInternetViewVisibility(true)
//                return
//            }
            
//            showToast(with: "Tidak ada koneksi internet")
            return
        }

        let loadPage = reset ? 0 : (page + 1)
        let request = NotificationTransactionRequest(page: loadPage, size: 10, types: "")
        
        mainView.startLoading()
        mainView.setNoInternetViewVisibility(false)
        
        isLoading = true
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            self.mainView.stopLoading()
            
            switch result {
            case let .success(data):
                self.page = loadPage
                
                if reset {
                    self.mainView.setData(data: data.content)
                    return
                }
                
                self.mainView.appendData(data: self.unique(data: data.content))
                
            case .failure(_):
                self.showToast(with: "Terjadi kesalahan")
            }
        }
    }
    
    func unique(data: [NotificationTransactionItem]) -> [NotificationTransactionItem] {
        var items: [NotificationTransactionItem] =  []
        
        for datum in data {
            if !items.contains(datum) && !mainView.data.contains(datum) {
                items.append(datum)
            }
        }
        
        return items
    }
}

// MARK: - View Delegate
extension TransactionController: TransactionViewDelegate {
    func didSelected(item: NotificationTransactionItem) {
        router?.navigateToDetail(with: item)
    }
    
    func didRefresh() {
        load(reset: true)
    }
    
    func didLoadMore() {
        load(reset: false)
    }
}

// MARK: - Gesture Back
extension TransactionController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TransactionController {
    private func readNotif() {
        readUpdater.update(.init(type: .transaction)) { result in
            switch result {
            case let .failure(error):
                print("Failed read transaction notification with error: \(error.localizedDescription)")
            case .success(_):
                print("Success read transaction notification..")
                NotificationCenter.default.post(name: Notification.Name("com.kipaskipas.updateNotificationCounterBadge"), object: nil)
            }
        }
    }
}
