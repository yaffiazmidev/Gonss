import UIKit
import KipasKipasShared

public class VerifyIdentityInputPhoneNumberController: UIViewController {

    private lazy var mainView: VerifyIdentityInputPhoneNumberView = {
        let view = VerifyIdentityInputPhoneNumberView()
        return view
    }()
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()
    
    public var handleDidSavePhoneNumber: ((String) -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        mainView.didSavePhoneNumber = { [weak self] phoneNumber in
            guard let self = self else { return }
            self.handleSavePhoneNumberToLocal(with: phoneNumber)
        }
        
        mainView.closeContainerStack.addTapGesture { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }
    
    public override func loadView() {
        view = mainView
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.phoneNumberTextField.becomeFirstResponder()
    }
    
    private func handleSavePhoneNumberToLocal(with value: String) {
        var storedItem: VerifyIdentityStored = verifyIdentityStored.retrieve() ?? .init()
        storedItem.userMobile = value
        storedItem.isPhoneNumberUpdated = true
        verifyIdentityStored.insert(storedItem) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.handleDidSavePhoneNumber?(value)
            }
        }
    }
}
