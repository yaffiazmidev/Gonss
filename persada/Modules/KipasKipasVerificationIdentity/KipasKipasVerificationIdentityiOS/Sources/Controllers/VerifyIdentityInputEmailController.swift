import UIKit
import KipasKipasShared

class VerifyIdentityInputEmailController: UIViewController {

    private lazy var mainView: VerifyIdentityInputEmailView = {
        let view = VerifyIdentityInputEmailView()
        return view
    }()
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()
    
    public var handleDidSaveEmail: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        mainView.didSaveEmail = { [weak self] email in
            guard let self = self else { return }
            self.handleSaveEmailToLocal(with: email)
        }
        
        mainView.closeContainerStack.addTapGesture { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.emailTextField.becomeFirstResponder()
    }
    
    private func handleSaveEmailToLocal(with value: String) {
        var storedItem: VerifyIdentityStored = verifyIdentityStored.retrieve() ?? .init()
        storedItem.userEmail = value
        storedItem.isEmailUpdated = true
        verifyIdentityStored.insert(storedItem) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.handleDidSaveEmail?(value)
            }
        }
    }
}
