import Foundation
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasVerificationIdentity
import KipasKipasCamera

public protocol IVerifyIdentityUploadViewModel {
    var uploadIdentityParam: VerifyIdentityUploadParam { get set }
    
    func uploadIdentity()
    func uploadPicture(with item: KKMediaItem, type: VerifyIdentityCameraType)
    func uploadPicture(with data: Data?, ext: String?, type: VerifyIdentityCameraType)
}

public protocol VerifyIdentityUploadViewModelDelegate: AnyObject {
    func displayUploadIdentity()
    func displayUploadPicture()
    func displayErrorUploadIdentity(with error: KKNetworkError)
    func displayErrorUploadPicture(with error: KKNetworkError, type: VerifyIdentityCameraType)
}

public class VerifyIdentityUploadViewModel: IVerifyIdentityUploadViewModel {
    
    public weak var delegate: VerifyIdentityUploadViewModelDelegate?
    public var uploadIdentityParam: VerifyIdentityUploadParam = VerifyIdentityUploadParam()
    private let uploader: VerifyIdentityUploader
    private let mediaUploader: MediaUploader
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()
    
    public init(
        uploader: VerifyIdentityUploader,
        mediaUploader: MediaUploader
    ) {
        self.uploader = uploader
        self.mediaUploader = mediaUploader
    }
    
    public func uploadIdentity() {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayErrorUploadIdentity(with: .connectivity)
            return
        }
        
        uploadIdentityParam.email = verifyIdentityStored.retrieve()?.userEmail ?? ""
        uploadIdentityParam.phone = verifyIdentityStored.retrieve()?.userMobile ?? ""
        
        uploader.upload(uploadIdentityParam) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                guard let error = error as? KKNetworkError else {
                    self.delegate?.displayErrorUploadIdentity(with: .general(error))
                    return
                }
                
                guard ReachabilityNetwork.isConnectedToNetwork() else {
                    self.delegate?.displayErrorUploadIdentity(with: .connectivity)
                    return
                }
                self.delegate?.displayErrorUploadIdentity(with: error)
            case .success(_):
                var storedItem = verifyIdentityStored.retrieve() ?? .init()
                storedItem.isEmailUpdated = false
                storedItem.isPhoneNumberUpdated = false
                verifyIdentityStored.insert(storedItem, completion: {_ in})
                self.delegate?.displayUploadIdentity()
            }
        }
    }
    
    public func uploadPicture(with item: KKMediaItem, type: VerifyIdentityCameraType) {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayErrorUploadPicture(with: .connectivity, type: type)
            return
        }
        
        guard let data = item.data,
              let uiImage = UIImage(data: data),
              let ext = item.path.split(separator: ".").last
        else {
            delegate?.displayErrorUploadPicture(with: .invalidData, type: type)
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "\(ext)")
        mediaUploader.upload(request: request) { [weak self] (result) in
            guard let self = self else { return }
            switch result{
            case .success(let response):
                
                let media = ResponseMedia(
                    id: nil,
                    type: "image",
                    url: response.tmpUrl,
                    thumbnail: Thumbnail(large: response.url, medium: response.url, small: response.url),
                    metadata: Metadata(
                        width: "\(uiImage.size.width * uiImage.scale)",
                        height: "\(uiImage.size.height * uiImage.scale)",
                        size: "0"
                    )
                )
                
                if type == .identity {
                    uploadIdentityParam.identityUrl = response.url
                } else {
                    uploadIdentityParam.selfieUrl = response.url
                }
                self.delegate?.displayUploadPicture()
            case .failure(let error):
                self.delegate?.displayErrorUploadPicture(
                    with: .responseFailure(KKErrorNetworkResponse(code: "0", message: error.localizedDescription)), type: type
                )
            }
        }
    }
    
    public func uploadPicture(with data: Data?, ext: String?, type: VerifyIdentityCameraType) {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            delegate?.displayErrorUploadPicture(with: .connectivity, type: type)
            return
        }
        
        guard let data = data, let ext = ext else {
            delegate?.displayErrorUploadPicture(with: .invalidData, type: type)
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "\(ext)")
        mediaUploader.upload(request: request) { [weak self] (result) in
            guard let self = self else { return }
            switch result{
            case .success(let response):
                
                if type == .identity {
                    uploadIdentityParam.identityUrl = response.url
                } else {
                    uploadIdentityParam.selfieUrl = response.url
                }
                self.delegate?.displayUploadPicture()
            case .failure(let error):
                self.delegate?.displayErrorUploadPicture(
                    with: .responseFailure(KKErrorNetworkResponse(code: "0", message: error.localizedDescription)), type: type
                )
            }
        }
    }
}

struct ResponseMedia {
    let id: String?
    let type: String?
    let url: String?
    let thumbnail: Thumbnail?
    let metadata: Metadata?
    let vodFileId: String?
    let vodUrl: String?
    
    init(
        id: String?,
        type: String?,
        url: String?,
        thumbnail: Thumbnail?,
        metadata: Metadata?,
        vodFileId: String? = nil,
        vodUrl: String? = nil
    ) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.vodFileId = vodFileId
        self.vodUrl = vodUrl
    }
}

struct Thumbnail {
    var large: String?
    var medium: String?
    var small: String?
}


struct Metadata {
    let width: String?
    let height: String?
    let size: String?
    var duration: Double?
}
