import UIKit
import Combine
import KipasKipasShared
import KipasKipasRegister

public final class RegisterUsernameViewController: StepsController {
    
    private let mainView = RegisterUsernameView()
        
    var checkAvailability: Closure<RegisterAccountAvailabilityParam>?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    private func observe() {
        mainView.onTapNext = { [weak self] username in
            guard let self = self else { return }
            storedData.username = username.lowercased()
            checkAvailability?(.username(username))
        }
    }
    
    override func setLoading(_ isLoading: Bool) {
        mainView.setLoading(isLoading)
    }
}

// MARK: ResourceView, ResourceLoadingView, ResourceErrorView
extension RegisterUsernameViewController: ResourceView {
    public func display(view viewModel: RegisterAccountAvailabilityViewModel) {
        guard viewModel.isExists == false else {
            return
        }
        delegate?.complete(step: self)
    }
}

extension RegisterUsernameViewController: ResourceLoadingView {
    public func display(loading loadingViewModel: ResourceLoadingViewModel) {
        mainView.setLoading(loadingViewModel.isLoading)
    }
    
    public func shouldHideLoadingWhenResourceReceived() -> Bool {
        return false
    }
}

extension RegisterUsernameViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        guard let error = errorViewModel.error else { return }
        mainView.setErrorText(error.message ?? "")
    }
}

private extension RegisterUsernameViewController {
    func configureUI() {
        view.backgroundColor = .white
        
        configureUsernameView()
    }
 
    func configureUsernameView() {
        mainView.backgroundColor = .clear
        scrollContainer.addArrangedSubViews(spacer(32))
        scrollContainer.addArrangedSubViews(mainView)
    }
}

