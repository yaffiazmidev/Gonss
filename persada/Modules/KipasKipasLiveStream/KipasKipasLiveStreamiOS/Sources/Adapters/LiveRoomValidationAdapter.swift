import Foundation
import Combine
import KipasKipasLiveStream
import KipasKipasNetworking
import KipasKipasShared

protocol LiveRoomValidationAdapterDelegate: AnyObject {
    func validationResult(_ result: LiveStreamValidation)
    func validationResult(_ error: LiveStreamEndpoint.ValidationError)
}

final class LiveRoomValidationAdapter {
    
    private let loader: () -> LiveValidationLoader
    
    private var cancellable: AnyCancellable?
    
    weak var delegate: LiveRoomValidationAdapterDelegate?
    
    init(loader: @escaping () -> LiveValidationLoader) {
        self.loader = loader
    }
    
    func validate() {
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case .failure(let failure) = result {
                    self?.delegate?.validationResult(failure)
                }
            }, receiveValue: { [weak self] result in
                self?.delegate?.validationResult(result.data)
            })
    }
}
