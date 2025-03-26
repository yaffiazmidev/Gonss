//
//  SplashScreenController.swift
//  Persada
//
//  Created by Muhammad Noor on 05/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Lottie
import SendBirdUIKit
import SendBirdSDK

class SplashScreenController: UIViewController {
    
    let animationView = AnimationView()
    let titleLabel: UILabel = {
        let label = UILabel(font: .Roboto(.medium, size: 12), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let mainTabController = MainTabController()
    
    func configureNotification(){
        mainTabController.feedController.notifsNavigate.configureNotif()
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
		view.backgroundColor = .white
		
		let animation = Animation.named(.get(.logo), subdirectory: .get(.lottie))
		animationView.animation = animation
		animationView.contentMode = .scaleAspectFit
		view.addSubview(animationView)
		view.addSubview(titleLabel)
		animationView.fillSuperview()

		let redValueProvider = ColorValueProvider(Color(r: 1, g: 0.2, b: 0.3, a: 1))
		animationView.setValueProvider(redValueProvider, keypath: AnimationKeypath(keypath: "Switch Outline Outlines.**.Fill 1.Color"))
		animationView.setValueProvider(redValueProvider, keypath: AnimationKeypath(keypath: "Checkmark Outlines 2.**.Stroke 1.Color"))
		
		if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			self.titleLabel.text = "Version" + version
		}
		
		titleLabel.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 70, paddingBottom: 60, paddingRight: 70, height: 30)

		
        if AUTH.isLogin() {
            RefreshTokenPresenter.shared.refreshToken { _ in
                self.routeToHome(deadline: .now())
            }
        } else {
            self.routeToHome(deadline: .now() + 2)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowOnboardingView), name: .showOnboardingView, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play(
            fromProgress: 0,
            toProgress: 1,
            loopMode: LottieLoopMode.playOnce,
            completion: { (finished) in
                if finished {
                    print("Animation Complete")
                } else {
                    print("Animation cancelled")
                }
            })
    }
    
    @objc func handleShowOnboardingView() {
        if AUTH.isLogin() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let mainTabController = MainTabController()
                mainTabController.modalPresentationStyle = .fullScreen
                self.present(mainTabController, animated: false, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                let login = LoginViewController(mainView: LoginView(), dataSource: LoginModel.DataSource())
                login.modalPresentationStyle = .fullScreen
                self.present(login, animated: false, completion: nil)
            }
        }
    }
    
    func routeToHome(deadline: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.mainTabController.modalPresentationStyle = .fullScreen
            self.present(self.mainTabController, animated: false, completion: nil)
        }
    }
}
