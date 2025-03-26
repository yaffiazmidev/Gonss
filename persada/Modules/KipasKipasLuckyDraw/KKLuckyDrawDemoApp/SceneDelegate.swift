import UIKit
import KipasKipasLuckyDraw
import KipasKipasLuckyDrawiOS
import KipasKipasShared

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        UIFont.loadCustomFonts
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let root = GiftBoxDummyViewController()
        root.didSelectGiftBox = { [weak self] in
            self?.showGiftBoxDetail(viewModel: $0)
        }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = root
        window.makeKeyAndVisible()
        
        self.window = window
    }
}

// MARK: Factory
extension SceneDelegate {
    // MARK: GiftBoxDetail
    private func makeGiftBoxDetailViewController(viewModel: GiftBoxViewModel) -> UIViewController {
        let parameter = GiftBoxDetailUIComposer.Parameter(viewModel: viewModel)
        let loader = GiftBoxDetailUIComposer.Loader(
            followLoader: .init(publisher: makeGiftBoxOwnerFollowLoader),
            joinLoader: .init(publisher: makeGiftBoxJoinLoader),
            detailLoader: .init(publisher: makeGiftBoxDetailLoader)
        )
        let callback = GiftBoxDetailUIComposer.Callback(
            showPrizeClaimStatus: showPrizeClaimViewController
        )
        let controller = GiftBoxDetailUIComposer.composeWith(
            parameter: parameter,
            loader: loader, 
            callback: callback
        )
        return controller
    }
    
    private func showGiftBoxDetail(viewModel: GiftBoxViewModel) {
        let destination = makeGiftBoxDetailViewController(viewModel: viewModel)
        presentWithCoverAnimation(
            configuration: PresentationUIConfiguration(
                cornerRadius: 15,
                corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            ),
            size: destination as! PresentationSizeProtocol,
            destination
        )
    }
    
    private func makeGiftBoxOwnerFollowLoader(_ userId: Int) -> API<GiftBoxEmptyData, AnyError> {
        let data = GiftBoxEmptyData(code: "1000", message: "General success")
        return Result<GiftBoxEmptyData, AnyError>
            .success(data)
            .delayOutput(for: 2)
            .eraseToAnyPublisher()
    }
    
    private func makeGiftBoxJoinLoader(_ id: Int) -> API<GiftBoxData, AnyError> {
        let data = GiftBoxData(
            code: "1000",
            message: "General success",
            data: .mock(
                .init(
                    lotteryType: "DRAWWINNER",
                    isJoined: true
                )
            )
        )
        return Result<GiftBoxData, AnyError>
            .success(data)
            .delayOutput(for: 2)
            .eraseToAnyPublisher()
    }
    
    private func makeGiftBoxDetailLoader(_ id: Int) -> API<GiftBoxData, AnyError> {
        let data = GiftBoxData(
            code: "1000",
            message: "General success",
            data: .mock(
                .init(
                    giftName: "Samsung Flip Z",
                    isJoined: true
                )
            )
        )
        return Result<GiftBoxData, AnyError>
            .success(data)
            .publisher
            .eraseToAnyPublisher()
    }
    
    // MARK: PrizeClaim
    private func makePrizeClaimViewController(_ viewModel: GiftBoxViewModel) -> UIViewController {
        let parameter = PrizeClaimUIComposer.Parameter(
            selfAccountId: "1",
            viewModel: viewModel
        )
        let controller = PrizeClaimUIComposer.composeWith(parameter: parameter)
        return controller
    }
    
    private func showPrizeClaimViewController(_ viewModel: GiftBoxViewModel) {
        let destination = makePrizeClaimViewController(viewModel)
        presentWithCoverAnimation(destination)
    }
}

extension SceneDelegate {
    func presentWithCoverAnimation(
        configuration: PresentationUIConfiguration = PresentationUIConfiguration(),
        size: PresentationSizeProtocol = PresentationSize(),
        _ destinationViewController: UIViewController
    ) {
        guard let top = window?.topViewController else { return }
        
        let interaction = InteractionConfiguration(
            presentingViewController: top,
            completionThreshold: 0.5,
            dragMode: .canvas
        )
        
        let cover = CoverPresentation(
            directionShow: .bottom,
            directionDismiss: .bottom,
            uiConfiguration: configuration,
            size: size,
            alignment: PresentationAlignment(vertical: .bottom, horizontal: .center),
            interactionConfiguration: interaction
        )
        let animator = Animator(presentation: cover)
        animator.prepare(presentedViewController: destinationViewController)
        destinationViewController.presentationAnimator = animator
        
        window?.topViewController?.present(destinationViewController, animated: true)
    }
}

extension UIWindow {
    var topNavigationController: UINavigationController?  {
        return topViewController?.navigationController
    }
    
    private class func topViewController(_ base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            let top = topViewController(nav.visibleViewController)
            return top
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                let top = topViewController(selected)
                return top
            }
        }
        
        if let presented = base?.presentedViewController {
            let top = topViewController(presented)
            return top
        }
        return base
    }
    
    var topViewController: UIViewController? {
        return UIWindow.topViewController(rootViewController)
    }
}
