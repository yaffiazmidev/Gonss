import Foundation
import KipasKipasShared
import KipasKipasVerificationIdentity

public protocol IVerifyIdentityRouter {
    func presentInfoCheck(by type: VerifyIdentityInfoCheckView.ViewType)
    func navigateToSelectId()
    func presentChannelFeeAwards()
    func presentMarkInfo()
    func presentFAQ()
    func navigateToUploadStatus()
}

public class VerifyIdentityRouter: IVerifyIdentityRouter {
    
    public weak var controller: VerifyIdentityController?
    public var handleBackToBalanceView: (() -> Void)?
    
    public init(handleBackToBalanceView: (() -> Void)?) {
        self.handleBackToBalanceView = handleBackToBalanceView
    }
    
    public func presentInfoCheck(by type: VerifyIdentityInfoCheckView.ViewType) {
        let view = VerifyIdentityInfoCheckView()
        let bottomSheetConfig = KKBottomSheetConfigureItem(viewHeight: type == .limit ? 316 : 407, canSlideUp: false, canSlideDown: false)
        let vc = KKBottomSheetController(view: view, configure: bottomSheetConfig)
        view.handleDismiss = vc.animateDismissView
        view.setupViewType(with: type)
        view.addUserMobileLabel.addTapGesture { [weak self] in
            guard let self = self else { return }
            vc.animateDismissView(completion: presentInputPhoneNumber)
        }
        
        view.addEmailLabel.addTapGesture { [weak self] in
            guard let self = self else { return }
            vc.animateDismissView(completion: presentInputEmail)
        }
        
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: false)
    }
    
    public func navigateToSelectId() {
        let countryLoader: VerifyIdentityCountryLoader = VerifyIdentityLoaderFactory.shared.get(.country)
        let viewModel = VerifyIdentitySelectIdViewModel(countryLoader: countryLoader)
        let vc = VerifyIdentitySelectIdController(viewModel: viewModel, handleBackToBalanceView: handleBackToBalanceView)
        viewModel.delegate = vc
        controller?.push(vc)
    }
    
    public func presentChannelFeeAwards() {
        let view = VerifyIdentityChannelFeeAwardsView()
        let bottomSheetConfig = KKBottomSheetConfigureItem(
            viewHeight: 215, canSlideUp: false, canSlideDown: false, isShowHeaderView: false
        )
        let vc = KKBottomSheetController(view: view, configure: bottomSheetConfig)
        view.handleDismiss = vc.animateDismissView
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: false)
    }
    
    public func presentMarkInfo() {
        let view = VerifyIdentityMarkInfoView()
        let bottomSheetConfig = KKBottomSheetConfigureItem(
            viewHeight: 378, canSlideUp: false, canSlideDown: false, isShowHeaderView: false
        )
        let vc = KKBottomSheetController(view: view, configure: bottomSheetConfig)
        view.handleOnTapConfirm = vc.animateDismissView
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: false)
    }
    
    public func presentFAQ() {
        let view = VerifyIdentityFAQView()
        let vc = KKBottomSheetController(view: view, title: "FAQ.", configure: .init(viewHeight: 600))
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: false)
    }
    
    public func navigateToUploadStatus() {
        let statusLoader: VerifyIdentityStatusLoader = VerifyIdentityLoaderFactory.shared.get(.verificationStatus)
        let viewModel = VerifyIdentityUploadStatusViewModel(statusLoader: statusLoader)
        let vc = VerifyIdentityUploadStatusController(
            viewModel: viewModel,
            handleBackToBalanceView: handleBackToBalanceView
        )
        viewModel.delegate = vc
        controller?.push(vc)
    }
}

extension VerifyIdentityRouter {
    private func presentInputEmail() {
        let vc = VerifyIdentityInputEmailController()
        vc.handleDidSaveEmail = { [weak self] _ in
            guard let self = self else { return }
//            self.updateUserStoredData()
        }
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: true)
    }
    
    private func presentInputPhoneNumber() {
        let vc = VerifyIdentityInputPhoneNumberController()
        vc.handleDidSavePhoneNumber = { [weak self] _ in
            guard let self = self else { return }
//            self.updateUserStoredData()
        }
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: true)
    }
}
