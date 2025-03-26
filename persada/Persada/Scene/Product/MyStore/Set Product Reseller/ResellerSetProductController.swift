//
//  ResellerSetProductController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import KipasKipasNetworking
import KipasKipasShared

class ResellerSetProductController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var resellerProductPriceTextField: UITextField!
    @IBOutlet weak var resellerCommissionTextField: UITextField!
    @IBOutlet weak var saveChangeButton: UIButton!
    @IBOutlet weak var stopResellerButton: UIButton!
    
    var setter: ResellerProductSetter!
    var updater: ResellerProductUpdater!
    var stopper: ResellerProductStopper!
    var onSuccess: (() -> Void)?
    
    private let product: ProductItem
    private lazy var hud = {
        return CPKProgressHUD.progressHUD(style: .loading(text: nil))
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupIQKeyboardManager()
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupAddTarget()
        setupAction()
        setupView()
    }
    
    required init(_ product: ProductItem){
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ResellerSetProductController {
    private func setupNavBar() {
        title = .get(.productForReseller)
        navigationController?.hideKeyboardWhenTappedAround()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)),
                                                           style: .plain, target: self, action: #selector(back))
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupIQKeyboardManager() {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100
    }
    
    private func setupView(){
        productImageView.loadImage(at: product.medias?.first?.thumbnail?.large ?? "", low: product.medias?.first?.thumbnail?.small ?? "", .w360, .w40)
        productTitleLabel.text = product.name
        productPriceLabel.text = product.price.toMoney()
        stopResellerButton.isHidden = !product.isResellerAllowed
        if product.isResellerAllowed {
            resellerProductPriceTextField.text = product.modal?.toMoney().replacingOccurrences(of: "Rp ", with: "")
            resellerCommissionTextField.text = product.commission?.toMoney().replacingOccurrences(of: "Rp ", with: "")
        }
        if !product.isResellerAllowed {
            saveChangeButton.setTitle("Simpan & Aktifkan Produk Reseller")
        }
        enableSaveButton()
    }
}

extension ResellerSetProductController {
    private func setupAddTarget() {
        resellerProductPriceTextField.addTarget(self, action: #selector(didChangeProductPrice(_:)), for: .editingChanged)
        resellerCommissionTextField.addTarget(self, action: #selector(didChangeResellerCommission(_:)), for: .editingChanged)
    }
    
    private func setupAction(){
        saveChangeButton.onTap(action:  product.isResellerAllowed ? update : save)
        stopResellerButton.onTap(action: showStopPopUp)
    }
    
    @objc private func didChangeProductPrice(_ textField: UITextField) {
        resellerProductPriceTextField.text = textField.text?.toMoneyWithoutRp()
        enableSaveButton()
    }
    
    @objc private func didChangeResellerCommission(_ textField: UITextField) {
        resellerCommissionTextField.text = textField.text?.toMoneyWithoutRp()
        enableSaveButton()
    }
    
    private func enableSaveButton() {
        let resellerProductPrice = Double(Int(resellerProductPriceTextField.text?.digits() ?? "0") ?? 0)
        let resellerCommission = Double(Int(resellerCommissionTextField.text?.digits() ?? "0") ?? 0)
        
        guard resellerProductPrice > 0, resellerCommission > 0 else {
            saveChangeButton.isEnabled = false
            saveChangeButton.backgroundColor = .primaryDisabled
            return
        }
        
        let productPrice = product.price
        let total = resellerProductPrice + resellerCommission
        saveChangeButton.isEnabled = total <= productPrice
        saveChangeButton.backgroundColor = saveChangeButton.isEnabled ? .primary : .primaryDisabled
    }
    
    private func showStopPopUp(){
        let vc = CustomPopUpViewController(title: "Apakah kamu yakin?", description:  "Setelah menghentikan fitur ini, produk akan dihapus dari etalase reseller dan mereka tidak bisa membantu kamu menjual produk ini lagi.", iconHeight: 90)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
        
        vc.iconImageView.image = UIImage(named: .get(.iconWarningRhombus))
        vc.titleLabel.textAlignment = .center
        vc.titleLabel.textColor = .black
        vc.titleLabel.font = .Roboto(.bold, size: 14)
        vc.descLabel.textAlignment = .center
        vc.descLabel.textColor = .grey
        vc.descLabel.font = .Roboto(.regular, size: 12)
        
        vc.mainStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        vc.mainStackView.spacing = 20
        vc.textStackView.spacing = 8
        
        vc.actionStackView.axis = .vertical
        vc.actionStackView.addArrangedSubview(vc.actionStackView.subviews[0])
        
        vc.okButton.backgroundColor = .red
        vc.okButton.setTitle("Ya, Hentikan Fitur Reseller")
        vc.handleTapOKButton = stop
        
        vc.cancelButton.backgroundColor = .whiteSmoke
        vc.cancelButton.isHidden = false
        vc.cancelButton.setTitle("Tidak, kembali ke pengaturan")
    }
}

extension ResellerSetProductController {
    private func save(){
        let modal = Int(resellerProductPriceTextField.text?.digits() ?? "0") ?? 0
        let commission = Int(resellerCommissionTextField.text?.digits() ?? "0") ?? 0
        let request = ResellerProductSetterRequest(id: product.id, modal: modal, commission: commission)
        self.hud.show(in: self.view)
        setter.set(request: request) { [weak self] result in
            guard let self = self else { return }
            self.hud.dismiss()
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.onSuccessAction()
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.displayAlertFailure(self.getErrorMessage(error))
                }
            }
        }
    }
    
    private func update(){
        let modal = Int(resellerProductPriceTextField.text?.digits() ?? "0") ?? 0
        let commission = Int(resellerCommissionTextField.text?.digits() ?? "0") ?? 0
        let request = ResellerProductUpdaterRequest(id: product.id, modal: modal, commission: commission)
        self.hud.show(in: self.view)
        updater.update(request: request) { [weak self] result in
            guard let self = self else { return }
            self.hud.dismiss()
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.onSuccessAction()
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.displayAlertFailure(self.getErrorMessage(error))
                }
            }
        }
    }
    
    private func stop(){
        let request = ResellerProductStopperRequest(id: product.id)
        self.hud.show(in: self.view)
        stopper.stop(request: request) { [weak self] result in
            guard let self = self else { return }
            self.hud.dismiss()
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.onSuccessAction()
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.displayAlertFailure(self.getErrorMessage(error))
                }
            }
        }
    }
    
    private func onSuccessAction(){
        self.onSuccess?()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func getErrorMessage(_ error: Error) -> String {
        if let error = error as? KKNetworkError {
            switch error {
            case .connectivity:
                return "Gagal menghubungkan ke server"
            case .invalidData:
                return "Gagal menyimpan perubahan"
            case .responseFailure(let error):
                return "Gagal memuat data\n\(error.message)"
            default:
                return error.localizedDescription
            }
        }
        
        return error.localizedDescription
    }
}


extension ResellerSetProductController: AlertDisplayer {
    private func displayAlertFailure(_ errorMessage: String){
        let action = UIAlertAction(title: .get(.ok), style: .default)
        self.displayAlert(with: .get(.failed), message: errorMessage, actions: [action])
    }
}
