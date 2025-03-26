import Foundation
import KipasKipasVerificationIdentity

public protocol IVerifyIdentityUploadStatusViewModel {
    func fetchStatus()
}

public protocol VerifyIdentityUploadStatusViewModelDelegate: AnyObject {
    func displayVerifyIdentityStatus(item: VerifyIdentityStatusItem)
    func displayError(with message: String)
}

public class VerifyIdentityUploadStatusViewModel: IVerifyIdentityUploadStatusViewModel {
    
    public weak var delegate: VerifyIdentityUploadStatusViewModelDelegate?
    private let statusLoader: VerifyIdentityStatusLoader
    
    public init(statusLoader: VerifyIdentityStatusLoader) {
        self.statusLoader = statusLoader
    }
    
    public func fetchStatus() {
        statusLoader.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                let dummy = VerifyIdentityStatusItem(
                    verifId: "345236",
                    accountId: "342",
                    submitAt: 74634533,
                    submitCount: 1,
                    type: "ktp",
                    country: "Indonesia",
                    accountName: "DENAZMI",
                    birthDate: "12-2-1992",
                    vendorVerificationStatus: "",
                    adminVerificationStatus: "revision",
                    identityUrl: "",
                    selfieUrl: "",
                    vendorUniqueId: "",
                    username: "azmi",
                    photo: "",
                    isVerified: true,
                    reason: "Silahkan ubah nomor yang kamu gukanan sebelumnya.",
                    reasonCategory: "No HP sudah digunakan",
                    accountPhoto: "",
                    phone: "081284756374",
                    email: "azmi@gmail.com",
                    isPhoneNumberRevision: true,
                    isEmailRevision: true
                )
                self.delegate?.displayVerifyIdentityStatus(item: response)
            }
        }
    }
}
