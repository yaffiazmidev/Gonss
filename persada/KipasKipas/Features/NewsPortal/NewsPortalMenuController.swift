//
//  NewsPortalMenuController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

class NewsPortalMenuController: UIViewController {
    
    private var mainView: NewsPortalMenuView?
    private let loader: NewsPortalLoader
    private var data: [NewsPortalData]
    private var quickAccessData: NewsPortalData?
    
    var showTitle: Bool = true
    var router: NewsPortalMenuRouting?
    var onDismiss: (() -> Void)?
    
    init(loader: NewsPortalLoader) {
        mainView = NewsPortalMenuView()
        self.loader = loader
        data = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        //print("****** deinit \(self)")
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupOnTap()
        loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainView?.delegate = nil
        mainView = nil
        router = nil
        
        onDismiss?()
    }
    
    func loadCache() {
        var quickAccessData: NewsPortalData
        let dataCache = KKCache.common.readData(key: .newsPortalQuickAccess)
        if let dataCache = dataCache,
           let cache = try? JSONDecoder().decode(NewsPortalData.self, from: dataCache) {
            quickAccessData = cache
        } else {
            var quickAccess: [NewsPortalItem] = []
            data.forEach { data in
                if data.categoryId != "quickAccess" {
                    data.content.forEach { item in
                        if item.defaultQuickAccess {
                            quickAccess.append(item)
                        }
                    }
                }
            }
            quickAccessData = NewsPortalData(
                category: "Akses Cepat",
                categoryId: "quickAccess",
                content: quickAccess
            )
        }
        
        self.quickAccessData = quickAccessData
        if data.first?.categoryId == "quickAccess" {
            data[0] = quickAccessData
        } else {
            data.insert(quickAccessData, at: 0)
        }
        mainView?.data = data
    }
}

private extension NewsPortalMenuController {
    private func setupOnTap() {
        mainView?.closeView.onTap { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        
        mainView?.dropdownView.onTap {
            
        }
        
        mainView?.searchIconView.onTap {
            
        }
    }
    
    private func setupView() {
        mainView?.showTitle = showTitle
        mainView?.delegate = self
    }
    
    private func loadData() {
        loader.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.data = data
                self.loadCache()
            case .failure(let error):
                print("NewsPortalMenuController fail load data:", error)
            }
        }
    }
    
    private func isChanged(oldItems: NewsPortalData, newItems: NewsPortalData) -> Bool {
        if oldItems.content.count != newItems.content.count {
            return true
        }
        
        var changed = false
        for item in newItems.content {
            if !oldItems.content.contains(where: { $0.id == item.id }){
                changed = true
                break
            }
        }
        
        return changed
    }
}

extension NewsPortalMenuController: NewsPortalMenuViewDelegate {
    func didOpen(_ item: NewsPortalItem) {
        router?.presentPortal(item.url)
    }
    
    func didQuickAccessAdd(_ item: NewsPortalItem, at index: Int?) {
        
        if data[0].content.contains(where: { $0.id == item.id }) { 
            Toast.share.show(message: "Portal sudah ada di Akses Cepat", backgroundColor: .black)
            return
        }
        
        if let index = index {
            data[0].content.insert(item, at: index)
        } else {
            data[0].content.append(item)
        }
        
        mainView?.data = data
    }
    
    func didQuickAccessRemove(_ item: NewsPortalItem) {
        data[0].content.removeAll(where: { $0.id == item.id })
        mainView?.data = data
    }
    
    func didQuickAccessSave() {
        let newItems = data[0]
        guard let oldItems = quickAccessData,
              isChanged(oldItems: oldItems, newItems: newItems),
              let data = try? newItems.jsonData()
        else { return }
        
        quickAccessData = newItems
        KKCache.common.save(data: data, key: .newsPortalQuickAccess)
    }
}
