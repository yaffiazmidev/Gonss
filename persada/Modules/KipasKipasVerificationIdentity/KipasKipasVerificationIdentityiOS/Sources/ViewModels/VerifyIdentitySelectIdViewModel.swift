import Foundation
import KipasKipasVerificationIdentity

public protocol IVerifyIdentitySelectIdViewModel {
    func fetchCountries()
}

protocol VerifyIdentitySelectIdViewModelDelegate: AnyObject {
    func displayCountries(with items: [VerifyIdentityCountryItem])
    func displayError(with error: Error)
}

public class VerifyIdentitySelectIdViewModel: IVerifyIdentitySelectIdViewModel {
    
    weak var delegate: VerifyIdentitySelectIdViewModelDelegate?
    
    private let countryLoader: VerifyIdentityCountryLoader
    
    public init(countryLoader: VerifyIdentityCountryLoader) {
        self.countryLoader = countryLoader
    }
    
    public func fetchCountries() {
        countryLoader.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error)
            case .success(let response):
                self.delegate?.displayCountries(with: response)
            }
        }
    }
}
