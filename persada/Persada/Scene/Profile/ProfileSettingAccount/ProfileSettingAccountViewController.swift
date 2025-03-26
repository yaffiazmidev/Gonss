//
//  ProfileSettingAccountViewController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

class ProfileSettingAccountViewController: UIViewController, Displayable, AlertDisplayer {
    
    private let mainView: ProfileSettingAccountView
    private var interactor: ProfileSettingAccountInteractable!
    private var router: ProfileSettingAccountRouting!
    private var presenter: ProfileSettingAccountPresenter!
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    let disposeBag = DisposeBag()
    var emailDiposable : Disposable?
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    required init(mainView: ProfileSettingAccountView, dataSource: ProfileSettingAccountModel.DataSource) {
        self.mainView = mainView
        
        super.init(nibName: nil, bundle: nil)
        self.presenter = ProfileSettingAccountPresenter()
        router = ProfileSettingAccountRouter(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.iconEllipsis))?.withRenderingMode(.alwaysOriginal),
                                                            style: .plain, target: self, action: #selector(onClickEllipse(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //interactor.doSomething(item: 22)
        setData()
    }
    
    @objc func onClickEllipse(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Please Select an Option", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: .get(.hapusAkun), style: .destructive , handler:{ [weak self] (UIAlertAction) in
            let vc = DeleteAccountRouter.create()
            self?.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
     
    func emailTextFieldListener(){
        mainView.emailCustomTextField.textField.rx.text.map { $0 ?? ""}.bind(to: presenter.emailBehaviorRelay).disposed(by: disposeBag)
        emailDiposable = presenter.isEmailValidRelay.bind { [weak self] (bool) in
            bool ? self?.mainView.emailCustomTextField.setActive(buttonTitle: StringEnum.simpan.rawValue) : self?.mainView.emailCustomTextField.showErrorLabel(message: StringEnum.errorEmail.rawValue, buttonTitle: StringEnum.simpan.rawValue)
        }
        
        
        mainView.emailCustomTextField.showErrorLabel(message: StringEnum.errorEmail.rawValue, buttonTitle: StringEnum.simpan.rawValue)
        
        mainView.emailCustomTextField.rightButton.rx.tap.subscribe { (_) in
            self.showDialog()
        }.disposed(by: disposeBag)
    }
    
    func setData(){
        mainView.usernameCustomTextField.textField.text = getUsername()
        decideEmailLayout(email: getEmail())
        mainView.phoneCustomTextField.textField.text = getPhone()
    }
    
    func decideEmailLayout(email : String?){
        if let mail = email {
            if !mail.isEmpty{
                DispatchQueue.main.async { [weak self] in
                    self?.emailDiposable?.dispose()
                    self?.mainView.emailCustomTextField.textField.text = mail
                    self?.mainView.backgroundOrange.isHidden = false
                    self?.mainView.emailCustomTextField.setInActiveDisappear()
                }
            } else {
                self.mainView.emailCustomTextField.setActive(buttonTitle: .get(.simpan))
            }
        }
    }
    
    func showDialog(){
        let alert = AlertDialogCustom.instance.createAlertDialog(dialogTitle: StringEnum.simpanEmail.rawValue, dialogDescription: StringEnum.simpanEmailDescription.rawValue, buttonNegativeText: StringEnum.batalkan.rawValue, buttonPositiveText: StringEnum.simpanEmail.rawValue)
        
        self.present(alert, animated: true, completion: nil)
        
        alert.onCancel = {
            print("Batalkan")
        }
        alert.onConfirm = {
            self.hud.show(in: self.view)
            DispatchQueue.main.async { [weak self] in
                self?.emailDiposable?.dispose()
                self?.mainView.backgroundOrange.isHidden = false
                let email = self?.mainView.emailCustomTextField.textField.text
                self?.presenter.updateEmail(email: email!, onSuccessUpdate: {
                    self?.hud.dismiss()
                    self?.mainView.emailCustomTextField.setInActiveDisappear()
                    LoginPreference.instance.email = email
                }, onFail: { error in
                    self?.hud.dismiss()
                    let action = UIAlertAction(title: .get(.close), style: .default, handler: {_ in
                        self?.mainView.emailCustomTextField.setActive(buttonTitle: StringEnum.simpan.rawValue)
                    })
                    self?.displayAlert(with: .get(.error), message: error, actions: [action])
                })
            }
        }
    }
    
    override func loadView() {
        view = mainView
        view.backgroundColor = .white
        setupNav()
        emailTextFieldListener()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    

    
  
}



// MARK: - Private Zone
private extension ProfileSettingAccountViewController {

    
    func setupNav(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "arrowleft"), style: .plain, target: self, action: #selector(self.back))
        
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func back(){
        router.routeTo(.dismissProfileSettingAccountScene)
    }
}
