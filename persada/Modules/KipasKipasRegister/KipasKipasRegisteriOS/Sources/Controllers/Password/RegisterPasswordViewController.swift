import UIKit
import Combine
import KipasKipasShared

public final class RegisterPasswordViewController: StepsController {
    
    private let mainView = RegisterPasswordView()
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    private func observe() {
        mainView.onTapNext = { [weak self] password in
            guard let self = self else { return }
            storedData.password = password
            delegate?.complete(step: self)
        }
    }
}

private extension RegisterPasswordViewController {
    func configureUI() {
        view.backgroundColor = .white
        
        configureMainView()
    }
    
    func configureMainView() {
        mainView.backgroundColor = .clear
        scrollContainer.addArrangedSubViews(spacer(32))
        scrollContainer.addArrangedSubViews(mainView)
    }
}
