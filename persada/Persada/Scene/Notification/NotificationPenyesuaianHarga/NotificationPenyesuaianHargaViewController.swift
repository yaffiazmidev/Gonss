//
//  NotificationPenyesuaianHargaViewController.swift
//  KipasKipas
//
//  Created by koanba on 01/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

class NotificationPenyesuaianHargaViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var labelTitlePesanan: UILabel!
    @IBOutlet weak var imageItem: UIImageView!
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var labelItemPrice: UILabel!
    @IBOutlet weak var labelItemQuantity: UILabel!
    
    @IBOutlet weak var labelTitleResi: UILabel!
    @IBOutlet weak var labelResi: UILabel!
    @IBOutlet weak var labelTitleOrderNo: UILabel!
    @IBOutlet weak var labelOrderNo: UILabel!
    @IBOutlet weak var labelTitleSendTo: UILabel!
    @IBOutlet weak var labelSendTo: UILabel!
    
    @IBOutlet weak var viewPenyesuaian: UIView!
    @IBOutlet weak var viewPoinPenyesuaian1: UIView!
    @IBOutlet weak var viewPoinPenyesuaian2: UIView!
    
    @IBOutlet weak var labelDescPenyesuaian: UILabel!
    @IBOutlet weak var labelPoinPenyesuaian1: UILabel!
    @IBOutlet weak var labelPoinPenyesuaian2: UILabel!
    
    @IBOutlet weak var viewDetailPenyesuaian: UIView!
    @IBOutlet weak var labelTitleOngkirAwal: UILabel!
    @IBOutlet weak var labelOngkirAwal: UILabel!
    @IBOutlet weak var labelTitleKurangBayar: UILabel!
    @IBOutlet weak var labelKurangBayar: UILabel!
    @IBOutlet weak var labelTitleTotalOngkir: UILabel!
    @IBOutlet weak var labelTotalOngkir: UILabel!
    
    @IBOutlet weak var labelMoreInfo: ActiveLabel!
    
    private let disposeBag = DisposeBag()
    
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    var viewModel: NotificationPenyesuaianHargaViewModel
    
    init(id: String) {
        self.viewModel = NotificationPenyesuaianHargaViewModel(id: id)
        super.init(nibName: "NotificationPenyesuaianHargaViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.registerObservers()
        viewModel.fetchData()
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
    
    func registerObservers() {
        viewModel.product
            .bind { product in
                if let product = product {
                    self.setupView(product: product)
                }
            }.disposed(by: disposeBag)
        
        viewModel.isLoading.subscribe(onNext: { [weak self] isLoading in
            guard let isLoading = isLoading else { return }
            if isLoading {
                guard let view = self?.view else { return }
                self?.hud.show(in: view)
                return
            } else {
                self?.hud.dismiss()
            }
        }).disposed(by: disposeBag)
        
        viewModel.error.bind { (error) in
            if !error!.isEmpty {
                self.showDialog(title: .get(.error), desc: error ?? .get(.errorUnknown))
            }
        }.disposed(by: disposeBag)
    }
    
    func showDialog(title: String, desc: String){
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .get(.ok), style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func initView() {
        view.backgroundColor = .white
        
        labelTitlePesanan.textColor = .black
        
        labelItemName.textColor = .black
        
        labelItemPrice.textColor = .contentGrey
        
        labelItemQuantity.textColor = .contentGrey
        
        labelTitleResi.textColor = .black
        
        labelResi.textColor = .grey
        
        labelTitleOrderNo.textColor = .black
        
        labelOrderNo.textColor = .secondary
        
        labelTitleSendTo.textColor = .black
        
        labelSendTo.textColor = .contentGrey
        
        labelDescPenyesuaian.textColor = .contentGrey
        
        labelPoinPenyesuaian1.textColor = .contentGrey
        
        labelPoinPenyesuaian2.textColor = .contentGrey
        
        labelTitleOngkirAwal.textColor = .contentGrey
        
        labelOngkirAwal.textColor = .contentGrey
        
        labelTitleKurangBayar.textColor = .contentGrey
        
        labelKurangBayar.textColor = .contentGrey
        
        labelTitleTotalOngkir.textColor = .black
        
        labelTotalOngkir.textColor = .black
        
        imageItem.layer.cornerRadius = 8
        
        viewPenyesuaian.backgroundColor = .secondaryLowTint
        viewPenyesuaian.layer.cornerRadius = 8
        
        viewPoinPenyesuaian1.backgroundColor = .contentGrey
        viewPoinPenyesuaian1.layer.cornerRadius = 4
        
        viewPoinPenyesuaian2.backgroundColor = .contentGrey
        viewPoinPenyesuaian2.layer.cornerRadius = 4
        
        viewDetailPenyesuaian.backgroundColor = .white
        viewDetailPenyesuaian.layer.cornerRadius = 4
        
        labelMoreInfo.textColor = .contentGrey
        labelMoreInfo.font = .Roboto(.regular, size: 12)
        labelMoreInfo.customize { label in
            let customType = ActiveType.custom(pattern: "\\s\(String.get(.penyesuaianOngkir))\\b")
            label.enabledTypes = [customType]
            labelMoreInfo.configureLinkAttribute = .some({ (ActiveType, _: [NSAttributedString.Key : Any], Bool) -> ([NSAttributedString.Key : Any]) in
                return [NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 12), NSAttributedString.Key.foregroundColor: UIColor.secondary]
            })
            label.handleCustomTap(for: customType) { element in
                print("PENYESUAIAN ONGKIR")
            }
        }
        
    }
    
    func setupView(product: TransactionProduct) {
        imageItem.loadImage(at: product.orderDetail?.urlProductPhoto ?? "")
        labelItemName.text = product.orderDetail?.productName
        labelItemPrice.text = product.orderDetail?.productPrice?.toMoney()
        labelItemQuantity.text = "\(product.orderDetail?.quantity ?? 0)x"
        labelResi.text = product.orderShipment?.awbNumber
        labelOrderNo.text = product.noInvoice
        labelOngkirAwal.text = product.orderShipment?.cost?.toMoney()
        labelKurangBayar.text = "+ \(product.orderShipment?.differentCost?.toMoney() ?? "")"
        labelTotalOngkir.text = product.orderShipment?.actualCost?.toMoney()
        
        let address = "\(product.orderShipment?.destinationLabel ?? ""), \(product.orderShipment?.destinationDetail ?? ""), Kecamatan \(product.orderShipment?.destinationSubDistrict ?? ""), Kota \(product.orderShipment?.destinationCity ?? ""), Provinsi \(product.orderShipment?.destinationProvince ?? ""), KODE POS: \(product.orderShipment?.destinationPostalCode ?? "")"
        labelSendTo.text = address
    }

}
