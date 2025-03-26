import KipasKipasRegister
import KipasKipasShared

protocol RequestOTPViewAdapterDelegate: AnyObject {
    func didRequestOTP(_ viewModel: RegisterRequestOTPViewModel)
}

final class RequestOTPViewAdapter: ResourceView {
    weak var delegate: RequestOTPViewAdapterDelegate?
    
    func display(view viewModel: RegisterRequestOTPViewModel) {
        delegate?.didRequestOTP(viewModel)
    }
}
