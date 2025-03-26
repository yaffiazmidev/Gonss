//
//  NotificationPreferencesViewController.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

class NotificationPreferencesViewController: UIViewController {

    @IBOutlet weak var pushNotificationContainer: UIStackView!
    @IBOutlet weak var labelOnOff: UILabel!
    
    @IBOutlet weak var labelSocialTitle: UILabel!
    @IBOutlet weak var labelSocialDescription: UILabel!
    @IBOutlet weak var switchSocial: UISwitch!
    
    @IBOutlet weak var labelTransactionTitle: UILabel!
    @IBOutlet weak var labelTransactionDescription: UILabel!
    @IBOutlet weak var switchTransaksi: UISwitch!
    
    @IBOutlet weak var labelCallTitle: UILabel!
    @IBOutlet weak var labelCallDescription: UILabel!
    @IBOutlet weak var switchCall: UISwitch!
    
    @IBOutlet weak var galleryAccessContainer: UIStackView!
    @IBOutlet weak var labelOnOffGalleryAccess: UILabel!
    
    private let delegate: NotificationPreferencesDelegate

    private var socialMediaToggle: Bool = true {
        didSet {
            switchSocial.isOn = socialMediaToggle
        }
    }
    
    private var transactionToggle: Bool = true {
        didSet {
            switchTransaksi.isOn = transactionToggle
        }
    }
    
    private var callToggle: Bool = true {
        didSet {
            switchCall.isOn = callToggle
        }
    }
    
    private var isPermissionAllowed: Bool = true {
        didSet {
            changeOnOffLabel(pushNotificationStatus: isPermissionAllowed)
        }
    }
    
    private var isPermissionGalleryAllowed: Bool = true {
        didSet {
            changeOnOffLabelGallery(galleryAccessStatus: isPermissionGalleryAllowed)
        }
    }
    
    @IBOutlet weak var socialSwitchContainer: UIStackView!
    @IBOutlet weak var transactionSwitchContainer: UIStackView!
    @IBOutlet weak var callSwitchContainer: UIStackView!

    init(delegate: NotificationPreferencesDelegate) {
        self.delegate = delegate
        super.init(nibName: "NotificationPreferencesViewController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

        requestNotificationPreferences()
        requestNotificationPreferencesPermission()
        requestPhotoLibraryPreferencesPermission()
        registerClick()
        registerObserver()
        callToggle = KKCache.common.readBool(key: .enablePushCall) ?? true
    }
    
    private func setupView() {
        title = "Akses / Perizinan Aplikasi"

        let backImage = UIImage(named: "arrowleft")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(self.back))
    }
    
    private func registerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: .notifyWillEnterForeground, object: nil)
    }
    
    private func registerClick() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(routeToSetting))
        let notifGesture = UITapGestureRecognizer(target: self, action: #selector(routeToSetting))
        pushNotificationContainer.addGestureRecognizer(notifGesture)
        galleryAccessContainer.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func back(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func routeToSetting() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    @objc
    private func enterForeground() {
        requestNotificationPreferencesPermission()
        requestPhotoLibraryPreferencesPermission()
        requestNotificationPreferences()
    }
    
    private func requestNotificationPreferences() {
        let request = NotificationPreferencesRequest(code: "PUSH")
        delegate.didRequestNotificationPreferences(request: request)
    }

    private func requestNotificationPreferencesPermission() {
        delegate.didCheckNotificationPermissionStatus()
    }
    
    private func requestPhotoLibraryPreferencesPermission() {
        delegate.didCheckPhotoLibraryPermissionStatus()
    }
    
    private func changeOnOffLabel(pushNotificationStatus isOn: Bool) {
        labelOnOff.text = isOn ? "On" : "Off"
        isOn ? setViewActive() : setViewInActive()
    }
    
    private func changeOnOffLabelGallery(galleryAccessStatus isOn: Bool) {
        labelOnOffGalleryAccess.text = isOn ? "On" : "Off"
    }
    
    private func setViewActive() {
        labelSocialTitle.textColor = .black
        labelSocialDescription.textColor = .black
        switchSocial.onTintColor = .primary
        switchSocial.isUserInteractionEnabled = true
        
        labelTransactionTitle.textColor = .black
        labelTransactionDescription.textColor = .black
        switchTransaksi.onTintColor = .primary
        switchTransaksi.isUserInteractionEnabled = true
        
        labelCallTitle.textColor = .black
        labelCallDescription.textColor = .black
        switchCall.onTintColor = .primary
        switchCall.isUserInteractionEnabled = true
        
        remoteTapGestureForSwitchContainer()
    }
    
    private func setViewInActive() {
        labelSocialTitle.textColor = .grey.withAlphaComponent(0.4)
        labelSocialDescription.textColor = .contentGrey.withAlphaComponent(0.4)
        switchSocial.onTintColor = .primary.withAlphaComponent(0.4)
        switchSocial.isUserInteractionEnabled = false
        
        labelTransactionTitle.textColor = .grey.withAlphaComponent(0.4)
        labelTransactionDescription.textColor = .contentGrey.withAlphaComponent(0.4)
        switchTransaksi.onTintColor = .primary.withAlphaComponent(0.4)
        switchTransaksi.isUserInteractionEnabled = false
        
        labelCallTitle.textColor = .grey.withAlphaComponent(0.4)
        labelCallDescription.textColor = .contentGrey.withAlphaComponent(0.4)
        switchCall.onTintColor = .primary.withAlphaComponent(0.4)
        switchCall.isUserInteractionEnabled = false
        
        addTapGestureForSwitchContainer()
    }
    
    private func addTapGestureForSwitchContainer() {
        let socialTapGesture = UITapGestureRecognizer(target: self, action: #selector(showDialog))
        socialSwitchContainer.addGestureRecognizer(socialTapGesture)
        let transactionTapGesture = UITapGestureRecognizer(target: self, action: #selector(showDialog))
        transactionSwitchContainer.addGestureRecognizer(transactionTapGesture)
    }
    
    @objc
    private func showDialog() {
        let dialog = NotificationPreferencesDialogViewController {
            
        } onSettingClick: { [weak self] in
            self?.routeToSetting()
        }
        self.present(dialog, animated: true)
    }
    
    private func remoteTapGestureForSwitchContainer() {
        socialSwitchContainer.gestureRecognizers?.forEach({ [socialSwitchContainer] gesture in
            socialSwitchContainer?.removeGestureRecognizer(gesture)
        })
        
        transactionSwitchContainer.gestureRecognizers?.forEach({ [transactionSwitchContainer] gesture in
            transactionSwitchContainer?.removeGestureRecognizer(gesture)
        })
    }
    
    @IBAction func onSwitchSocialChange(_ sender: UISwitch) {
        socialMediaToggle.toggle()
        DispatchQueue.main.asyncDeduped(target: self, after: 0.25) { [weak self] in
            self?.requestUpdateNotificationPreferences(.social)
        }
    }
    
    @IBAction func onSwitchTransactionChange(_ sender: UISwitch) {
        transactionToggle.toggle()
        DispatchQueue.main.asyncDeduped(target: self, after: 0.25) { [weak self] in
            self?.requestUpdateNotificationPreferences(.shop)
        }
    }
    
    @IBAction func onSwitchCallChange(_ sender: UISwitch) {
        callToggle.toggle()
        KKCache.common.save(bool: callToggle, key: .enablePushCall)
        DispatchQueue.main.asyncDeduped(target: self, after: 0.25) { [weak self] in
            guard let self = self else { return }
            let actionSheet = UIAlertController(title: "Untuk menerapkan perubahan, anda harus memulai ulang aplikasi. Apakah ingin muat ulang sekarang ?", message: "", preferredStyle: .alert)
            
            let reloadAction = UIAlertAction(title: "Muat Ulang", style: .default) { _ in
                exit(EXIT_SUCCESS)
            }
            actionSheet.addAction(reloadAction)
            
            let cancelAction = UIAlertAction(title: "Nanti Saja", style: .cancel) { _ in
                
            }
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true)
        }
    }
    
    private func requestUpdateNotificationPreferences(_ type: NotificationPreferencesType) {
        let request = NotificationPreferencesUpdateRequest(
            code: "PUSH",
            socialmedia: socialMediaToggle,
            shop: transactionToggle)
        
        delegate.didUpdateNotificationPreferences(request: request, for: type)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateSocialToggelUIError(with errorMessage: String?) {
        guard let errorMessage = errorMessage else { return }
        Toast.share.show(message: errorMessage)
        socialMediaToggle.toggle()
    }
    
    private func updateTransactionToggelUIError(with errorMessage: String?) {
        guard let errorMessage = errorMessage else { return }
        Toast.share.show(message: errorMessage)
        transactionToggle.toggle()
    }
    
    private func showErrorToast(with errorMessage: String?) {
        guard let errorMessage = errorMessage else { return }
        Toast.share.show(message: errorMessage)
    }
}

extension NotificationPreferencesViewController: NotificationPreferencesView,
                                                 NotificationPreferencesLoadingView,
                                                 NotificationPreferencesErrorView {
    
    func display(_ viewModel: NotificationPreferencesViewModel) {
        let item = viewModel.item
        switchSocial.isOn = item.socialMediaPreferences
        switchTransaksi.isOn = item.shopPreferences
        socialMediaToggle = item.socialMediaPreferences
        transactionToggle = item.shopPreferences
    }
    
    func display(_ viewModel: NotificationPreferencesLoadingViewModel) {
        // TODO: Show Loading View
    }
    
    func display(_ viewModel: NotificationPreferencesLoadingErrorViewModel) {
        if isPermissionAllowed {
            showErrorToast(with: viewModel.message)
        }
    }
}

extension NotificationPreferencesViewController: UpdateNotificationPreferencesView, UpdateNotificationPreferencesLoadingView, UpdateNotificationPreferencesErrorView {
    
    func display(_ viewModel: UpdateNotificationPreferencesViewModel) {
        requestNotificationPreferences()
    }
    
    func display(_ viewModel: UpdateNotificationPreferencesLoadingViewModel) {
        // TODO: Show Loading View
    }
    
    func display(_ viewModel: UpdateNotificationPreferencesLoadingErrorViewModel) {
        switch viewModel.type {
        case .social:
            updateSocialToggelUIError(with: viewModel.message)
        case .shop:
            updateTransactionToggelUIError(with: viewModel.message)
        case .none:
            break
        }
    }
    
}

extension NotificationPreferencesViewController: PermissionNotificationPreferencesView {
    func display(_ viewModel: PermissionNotificationPreferencesViewModels) {
        isPermissionAllowed = viewModel.item.isPermissionAllowed
    }
}

extension NotificationPreferencesViewController: PermissionPhotoLibraryPreferencesView {
    func display(_ viewModel: PermissionPhotoLibraryPreferencesViewModels) {
        isPermissionGalleryAllowed = viewModel.item.isPermissionAllowed
    }
}
