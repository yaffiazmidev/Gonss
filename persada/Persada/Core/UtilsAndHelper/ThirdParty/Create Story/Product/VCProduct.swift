//
//  VCProduct.swift
//  AppVideo
//
//  Created by Icon+ Gaenael on 17/02/21.
//

import UIKit
import Combine

class VCProduct: UIViewController {

    private let vwHeader = ComponentViewHeader()
    private let vwSearch = ComponentViewSearch()
    private let tblView  = ComponentViewTable()
    private let vwLoading = UIActivityIndicatorView(style: .medium)
	
	private var subscriptions = Set<AnyCancellable>()
    
    //ROW
    private let nibNameRow = "RowTagProduct"
    
    //State
    private var data : [Product] = []
    
    var isFromPost = false
    //Action
    var actionSelect : (Product) -> () = { _ in }
    
    //Network
    private let model = ProductNetworkModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchDataProduct("")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFromPost {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isFromPost {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
}

extension VCProduct {
    
    private func setupView(){
        view.backgroundColor = .white
        
        vwHeader
            .addComponent(view)
            .setupView("Pilih Produk")
            .setupActionClick({
                if self.isFromPost {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
            .endFunction()
        
        vwSearch.addComponent(view)
            .setupView(.get(.cariProduk))
            .setupSearch({ keyword in
                self.fetchDataProduct(keyword)
            })
            .endFunction()
        
        tblView.addComponent(view)
               .setupView(.white, .none, 96)
               .setupInset(inset: UIEdgeInsets(top: -12, left: 0, bottom: 0, right: 0))
               .setupDelegate(registerCellNib: [nibNameRow], totalSection: {
                    return self.vwLoading.isAnimating ? 0 : 1
               }, totalRowSection: { section in
                    return self.data.count
               }, setupCell: { table, index in
                    let cell = table.dequeueReusableCell(withIdentifier: self.nibNameRow) as? RowTagProduct
                    cell?.setupData(self.data[index.row])
                   if self.data[index.row].stock ?? 0 < 1{
                       cell?.disable()
                   }
                    return cell ?? UITableViewCell()
               }, actionSelect: { index in
                  if self.data[index.row].stock ?? 0 < 1 { return }
                   
                    self.actionSelect(self.data[index.row])
                
                    if self.isFromPost {
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
               }, didScrol: {
                    self.view.endEditing(true)
               })
               .endFunction()
        
        vwLoading.color = .gray
        vwLoading.hidesWhenStopped = true
        vwLoading.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vwLoading)
        if isFromPost {
            
        }
        NSLayoutConstraint.activate([
            //MARK:: Header Constraint
			vwHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            vwHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vwHeader.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            vwHeader.heightAnchor.constraint(equalToConstant: 50),
            //MARK:: Search Constraint
            vwSearch.topAnchor.constraint(equalTo: vwHeader.bottomAnchor, constant: 24),
            vwSearch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            vwSearch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            vwSearch.heightAnchor.constraint(equalToConstant: 44),
            //MARK:: Table Constraint
            tblView.topAnchor.constraint(equalTo: vwSearch.bottomAnchor, constant: 24),
            tblView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tblView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tblView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            //MARK:: Loading Constraint
            vwLoading.topAnchor.constraint(equalTo: vwSearch.bottomAnchor, constant: 24),
            vwLoading.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}

extension VCProduct{
    private func fetchDataProduct(_ key: String){
        vwLoading.startAnimating()
        tblView.reloadData()
			let network = ProductNetworkModel()
			
			let userId = getIdUser()
			network.searchMyProducts(.searchListProductById(id: userId, text: key)).sink { completion in
				switch completion {
				case .failure:
					self.vwLoading.stopAnimating()
					self.tblView.reloadData()
				case .finished: break
				}
				} receiveValue: { model in
					self.vwLoading.stopAnimating()
					self.data = model.data?.content ?? []
					self.tblView.reloadData()
				}.store(in: &subscriptions)
    }
}

