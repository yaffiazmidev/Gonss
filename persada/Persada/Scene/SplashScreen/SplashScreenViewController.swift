//
//  SplashScreenViewController.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 09/11/21.
//

import UIKit
import KipasKipasDirectMessage
import FirebaseAnalytics
import KipasKipasNetworking

protocol SplashScreenViewControllerDisplayLogic: AnyObject {
	func displayFeed(_ feed: [Feed])
}

class SplashScreenViewController: UIViewController {
    let versionLabel: UILabel = {
        let label = UILabel(font: .Roboto(.medium, size: 12), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let iconImageView: UIImageView = {
//        let img = UIImageView(image:  UIImage(named: "iconKipasKipas_new"), contentMode: .scaleAspectFit)
//        img.translatesAutoresizingMaskIntoConstraints = false
        let img = UIImageView(image:  UIImage(named: "iconKipasKipas_new") )
        return img
    }()
    let bgImageView: UIImageView = {
        let img = UIImageView(image:  UIImage(named: "bg-launch-white") )
        return img
    }()
    
    private lazy var settings = UserDefaults.standard
    
    var interactor: SplashScreenInteractorBusinessLogic!
    private var mainTabController: MainTabController? = MainTabController()
    
    var feedData: [Feed] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        sendDeviceInfoToFirebaseAnalytics()
        view.backgroundColor = .white
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version" + version
        }
        
        //        handleFeedDataAndRouteTohome()
//        routeToHome()
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowOnboardingView), name: .showOnboardingView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowOnboardingViewAfterDeleteAccount), name: .showOnboardingViewAfterDeleteAccount, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(bgImageView)
        view.addSubview(iconImageView)
        view.addSubview(versionLabel)
        
        versionLabel.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 70, paddingBottom: 60, paddingRight: 70, height: 30)
        
        bgImageView.anchors.edges.pin(insets: 0, axis: .vertical)
        bgImageView.anchors.edges.pin(insets: 0, axis: .horizontal)
        
        iconImageView.anchor(width: 200, height: 66)
        iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func sendDeviceInfoToFirebaseAnalytics() {
        var params = getDeviceInfo()
        var username = getUsername().isEmpty ? "EMPTY" : getUsername()
        params["username"] = username
        Analytics.logEvent("device_info_\(username)", parameters: params)
    }

    func getDeviceInfo() -> [String: String] {
        var params: [String: String] = [:]
        let device = UIDevice.current

        params["model_name"] = UIDevice.modelName
        params["system_version"] = device.systemVersion

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            params["app_version"] = version
        }

        if let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            params["build_number"] = buildNumber
        }


        if let identifierForVendor = UIDevice.current.identifierForVendor {
            let uuidString = identifierForVendor.uuidString
            params["device_UUID"] = uuidString
        }

        return params
    }

    @objc func handleShowOnboardingView() {
        if !settings.hasRunBefore {
            settings.hasRun()
            removeToken()
        }
        
        if AUTH.isLogin() {
            navigateToMainVC()
            return
        }
        showLogin?()
    }
    
    @objc func handleShowOnboardingViewAfterDeleteAccount() {
        interactor.getHomeFeedFirstPage()
    }
    
    func configureNotification() {
        mainTabController?.notifsNavigate?.configureNotif()
    }
    
    private func handleFeedDataAndRouteTohome() {
        guard let feed = FeedSimpleCache.instance.getFeeds, !feed.isEmpty else {
            interactor.getHomeFeedFirstPage()
            return
        }
        
        //feedData = feed
//        routeToHome()
    }
    
    func navigateToMainVC() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let self = self else { return }
            self.mainTabController?.notifsNavigate?.cleanNotif()
            self.mainTabController?.notifsNavigate = nil
            self.mainTabController = nil
            let mainTabController = MainTabController()
            mainTabController.notifsNavigate?.configureNotif()
            mainTabController.modalPresentationStyle = .fullScreen
//            mainTabController.feedController.homeFVC = FeedFactory.createFeedController(feed: self.feedData, isHome: true)
            self.present(mainTabController, animated: false, completion: nil)
        }
    }
    
    func routeToHome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if !settings.hasRunBefore {
                settings.hasRun()
                removeToken()
            }
            
            if AUTH.isLogin() {
                self.navigateToMainVC()
                return
            }
            self.mainTabController?.modalPresentationStyle = .fullScreen
//            self.mainTabController?.feedController.homeFVC = FeedFactory.createFeedController(feed: self.feedData, isHome: true)
            guard let mainTabController = self.mainTabController else { return }
            self.present(mainTabController, animated: false, completion: nil)
        }
    }
}

extension SplashScreenViewController: SplashScreenViewControllerDisplayLogic {
    func displayFeed(_ feed: [Feed]) {
        feedData = feed
        FeedSimpleCache.instance.saveFeeds(feeds: feedData)
        routeToHome()
    }
}

extension SplashScreenViewController {
    func configure() -> SplashScreenViewController {
        let controller = SplashScreenViewController()
        let presenter = SplashScreenPresenter(controller: controller)
        let interactor = SplashScreenInteractor(presenter: presenter, feedUsecase: Injection.init().provideFeedUseCase())
        controller.interactor = interactor
        return controller
    }
}

private extension UserDefaults {
    enum Key: String {
        case hasRunBefore
    }

    var hasRunBefore: Bool {
        return bool(forKey: Key.hasRunBefore.rawValue)
    }
    
    func hasRun() {
        setValue(true, forKey: Key.hasRunBefore.rawValue)
    }
}
