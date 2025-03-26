import Foundation
import KipasKipasNetworking
import KipasKipasVerificationIdentity

public protocol IVerifyIdentityViewModel {
    func check()
}

public protocol VerifyIdentityViewModelDelegate: AnyObject {
    func displayCheckVerifyIdentity(item: VerifyIdentityCheckItem)
    func displayVerifyIdentityLimit()
    func displayError(with message: String)
}

public class VerifyIdentityViewModel: IVerifyIdentityViewModel {
    
    public weak var delegate: VerifyIdentityViewModelDelegate?
    
    private let checker: VerifyIdentityChecker
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()
    
    public init(checker: VerifyIdentityChecker) {
        self.checker = checker
    }
    
    public func check() {
        checker.check { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                guard let error = error as? VerifyIdentityError, error == .verifyIdentityLimit else {
                    self.delegate?.displayError(with: error.localizedDescription)
                    return
                }
                self.delegate?.displayVerifyIdentityLimit()
            case let .success(response):
                
                var storedData = self.verifyIdentityStored.retrieve()
                var item = response
                
                if item.emailValue.isEmpty {
                    item.emailValue = storedData?.userEmail ?? ""
                } else {
                    if storedData?.isEmailUpdated == true {
                        item.emailValue = storedData?.userEmail ?? ""
                    } else {
                        storedData?.userEmail = item.emailValue
                    }
                    
                    self.verifyIdentityStored.insert(storedData ?? .init(), completion: {_ in})
                }
                
                if item.phoneNumberValue.isEmpty {
                    item.phoneNumberValue = storedData?.userMobile ?? ""
                } else {
                    if storedData?.isPhoneNumberUpdated == true {
                        item.phoneNumberValue = storedData?.userMobile ?? ""
                    } else {
                        storedData?.userMobile = item.phoneNumberValue
                    }
                    
                    self.verifyIdentityStored.insert(storedData ?? .init(), completion: {_ in})
                }
                
                self.delegate?.displayCheckVerifyIdentity(item: item)
            }
        }
    }
}
