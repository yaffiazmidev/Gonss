import UIKit
import KipasKipasShared
import KipasKipasNotification

class SystemSettingTypesController: CustomHalfViewController {
    let mainView: SystemSettingTypesView
    
    let viewModel: ISystemSettingTypesViewModel
    let type: String
    var preferences: NotificationPreferencesItem = NotificationPreferencesItem()
    
    init(type: String, viewModel: ISystemSettingTypesViewModel) {
        mainView = SystemSettingTypesView()
        self.viewModel = viewModel
        self.type = type
        super.init(nibName: nil, bundle: nil)
        mainView.delegate = self
        mainView.setupComponentBy(type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        canSlideUp = false
        viewHeight = 324
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchPreferences()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        containerView.addSubview(mainView)
        mainView.anchors.leading.equal(containerView.anchors.leading)
        mainView.anchors.trailing.equal(containerView.anchors.trailing)
        mainView.anchors.top.equal(containerView.anchors.top)
        mainView.anchors.bottom.equal(containerView.safeAreaLayoutGuide.anchors.bottom)
    }
}

extension SystemSettingTypesController: SystemSettingTypesViewModelDelegate {
    func displayPreferences(with item: NotificationPreferencesItem) {
        preferences = item
        mainView.setupSwitch(types: type, item: item)
    }
    
    func displayError(with message: String) {
        print(message)
    }
}

// MARK: - Helper
private extension SystemSettingTypesController {}

extension SystemSettingTypesController: SystemSettingTypesViewDelegate {
    func didSwitch(types: String, isOn: Bool) {
        
        switch types {
        case "account":
            preferences.socialMediaAccount = isOn
            viewModel.updatePreferences(by: preferences)
        case "live":
            preferences.socialMediaLive = isOn
            viewModel.updatePreferences(by: preferences)
        case "hotroom":
            preferences.socialmedia = isOn
            viewModel.updatePreferences(by: preferences)
        default:
            break
        }
        
        
    }
    
    func didTapClose() {
        animateDismissView()
    }
}


protocol ISystemSettingTypesViewModel {
    func fetchPreferences()
    func updatePreferences(by item: NotificationPreferencesItem)
}

protocol SystemSettingTypesViewModelDelegate: AnyObject {
    func displayPreferences(with item: NotificationPreferencesItem)
    func displayError(with message: String)
}

class SystemSettingTypesViewModel: ISystemSettingTypesViewModel {
    
    public weak var delegate: SystemSettingTypesViewModelDelegate?
    private let preferencesLoader: NotificationPreferencesLoader
    private let preferencesUpdater: NotificationPreferencesUpdater
    
    init(
        preferencesLoader: NotificationPreferencesLoader,
        preferencesUpdater: NotificationPreferencesUpdater
    ) {
        self.preferencesLoader = preferencesLoader
        self.preferencesUpdater = preferencesUpdater
    }
    
    func fetchPreferences() {
        let request = NotificationPreferencesRequest(code: "push")
        preferencesLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.delegate?.displayPreferences(with: response)
            }
        }
    }
    
    func updatePreferences(by item: NotificationPreferencesItem) {
        let request = NotificationPreferencesUpdateRequest(
            code: "push",
            subCodes: SubCodes(
                socialmedia: item.socialmedia,
                socialMediaComment: item.socialMediaComment,
                socialMediaLike: item.socialMediaLike,
                socialMediaMention: item.socialMediaMention,
                socialMediaFollower: item.socialMediaFollower,
                socialMediaLive: item.socialMediaLive,
                socialMediaAccount: item.socialMediaAccount
            )
        )
        preferencesUpdater.update(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(_):
                print("Success update preferences..")
            }
        }
    }
}

