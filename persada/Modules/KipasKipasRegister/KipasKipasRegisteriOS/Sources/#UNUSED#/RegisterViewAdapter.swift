import KipasKipasShared
import KipasKipasRegister

protocol RegisterViewAdapterDelegate: AnyObject {
    func didFinishRegister(with errorViewModel: ResourceErrorViewModel)
    func didFinishRegister(with response: RegisterResponse)
}

final class RegisterViewAdapter: ResourceView, ResourceErrorView {
    
    weak var delegate: RegisterViewAdapterDelegate?
    
    func display(view viewModel: RegisterResponse) {
        delegate?.didFinishRegister(with: viewModel)
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        delegate?.didFinishRegister(with: errorViewModel)
    }
}

