//
//  ProfileSettingAccountPresenter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import RxSwift
import RxCocoa




final class ProfileSettingAccountPresenter {
    
    var emailBehaviorRelay : BehaviorRelay<String> = BehaviorRelay(value:"")
    var isEmailValidRelay : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    let disposeBag = DisposeBag()
    
    var profileUseCase : ProfileUseCase?
    
    
    init() {
        profileUseCase = Injection.init().provideProfileUseCase()
        emailInputListener()
    }
    
  
    func updateEmail(email: String, onSuccessUpdate: @escaping () -> (), onFail: @escaping (String) -> ())  {
        profileUseCase?.updateEmail(email: email).subscribeOn(concurrentBackground).observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            self.profileUseCase?.getNetworkProfile(id: getIdUser()).subscribe().disposed(by: self.disposeBag)
            self.notifyRedDot()
            onSuccessUpdate()
            print(" Success update email \(result)")
        }, onError: { (error) in
            print(" Error update email \(error)")
            if let error = error as? ErrorMessage {
                onFail(error.statusMessage ?? "Unknown error")
                return
            }
            onFail(error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    
    func notifyRedDot(){
        NotificationCenter.default.post(name: .notificationUpdateEmail, object: nil)
    }
    
    func emailInputListener(){
        emailBehaviorRelay.subscribe {[weak self] (input) in
            self?.isEmailValid(email: input).bind(to: self!.isEmailValidRelay).disposed(by: self!.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    func isEmailValid(email: String) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            observer.onNext(self.checkIfEmailValid(email: email))
            return Disposables.create { }
        }
    }

    
    func checkIfEmailValid(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    

    
}

