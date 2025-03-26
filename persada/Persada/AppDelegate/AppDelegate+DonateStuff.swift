import KipasKipasDonateStuffiOS
import UIKit
import Combine
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasDonateStuff
import KipasKipasShared
import KipasKipasImage
import KipasKipasNotificationiOS

var showDonateStuff: ((String, DonationItemRole) -> ())?

extension AppDelegate {
    
#warning("[BEKA] this should be removed")
    func configureDonateStuffFeature() {
        KipasKipas.showDonateStuff = { [weak self] (id, role) in
            self?.navigateToDonationItemList(donationId: id, role: role)
        }
        KipasKipasNotificationiOS.showDonationItemTransaction = { [weak self] id in
            self?.navigateToDonationItemPayment(orderId: id)
        }
    }
    
    private func makeImageLoader(url: URL) -> API<[String: Data], AnyError> {
        return RemoteImageLoader.shared
            .getPublisher(url: url)
            .tryMap({ data in
                return [url.absoluteString: data]
            })
            .mapError({ _ in return AnyError(code: "no-image") })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

// MARK: Loaders
private extension AppDelegate {
    private func makeDonationItemListLoader(_ param: String) -> API<DonationItemData, AnyError> {
        let publicPath = isAuthenticated ? "" : "/public"
        let client = isAuthenticated ? authenticatedHTTPClient : httpClient
        
        return client.getPublisher(
            request: .url(baseURL)
                .path("\(publicPath)/donations/\(param)/items")
                .method(.GET)
                .build()
        )
        .tryMap(Mapper<DonationItemData>.map)
        .mapError({
            error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .delayOutput(for: 1)
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    private func makeDonationItemDetailLoader(_ param: String) -> API<DonationItemDetailData, AnyError> {
        let publicPath = isAuthenticated ? "" : "/public"
        let client = isAuthenticated ? authenticatedHTTPClient : httpClient
        
        return client.getPublisher(
            request: .url(baseURL)
                .path("\(publicPath)/donations/items/\(param)")
                .method(.GET)
                .build()
        )
        .tryMap(Mapper<DonationItemDetailData>.map)
        .mapError({
            error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .delayOutput(for: 1)
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    private func makeDonationItemCheckoutLoader(_ param: DonationItemCheckoutRequest) -> API<DonationItemCheckoutData, AnyError> {
        return authenticatedHTTPClient.getPublisher(
            request: .url(baseURL)
                .path("/orders/donations-item")
                .method(.POST)
                .body(param)
                .build()
        )
        .tryMap(Mapper<DonationItemCheckoutData>.map)
        .mapError({
            error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .delayOutput(for: 1)
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    private func makeDonationItemPaymentLoader(_ param: String) -> API<DonationItemPaymentData, AnyError> {
        return authenticatedHTTPClient.getPublisher(
            request: .url(baseURL)
                .path("/orders/donations-item/\(param)")
                .method(.GET)
                .build()
        )
        .tryMap(Mapper<DonationItemPaymentData>.map)
        .mapError({
            error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .delayOutput(for: 1)
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
}

// MARK: Routing
private extension AppDelegate {
    func navigateToDonationItemList(donationId: String, role: DonationItemRole) {
        let destination = makeDonationItemListViewController(
            donationId: donationId,
            role: role
        )
        destination.hidesBottomBarWhenPushed = true
        destination.configureDismissablePresentation()
        
        let navigationController = UINavigationController(rootViewController: destination)
        presentWithSlideAnimation(navigationController)
    }
    
    private func navigateToDonationItemDetailViewController(id: String, role: DonationItemRole) {
        let destination = makeDonationItemDetailViewController(id: id, role: role)
        destination.configureDismissablePresentation(backIcon: .iconArrowLeftCircleBlack)
        
        let navigationController = UINavigationController(rootViewController: destination)
        presentWithSlideAnimation(navigationController)
    }
    
    
    func navigateToDonationItemCheckout(
        viewModel: DonationItemDetailViewModel,
        quantity: Int
    ) {
        let destination = makeDonationItemCheckoutViewController(
            viewModel: viewModel,
            quantity: quantity
        )
        destination.configureDismissablePresentation()
        
        let navigation = UINavigationController(rootViewController: destination)
        presentWithSlideAnimation(navigation)
    }
    
    func navigateToDonationItemPayment(orderId: String) {
        let destination = makeDonationItemPaymentViewController(orderId: orderId)
        destination.configureDismissablePresentation(backIcon: .iconChevronLeft)
        
        let navigationController = UINavigationController(rootViewController: destination)
        presentWithSlideAnimation(navigationController)
    }
}

// MARK: ViewController Factory
private extension AppDelegate {
    private func makeDonationItemListViewController(
        donationId: String,
        role: DonationItemRole
    ) -> UIViewController {
        let parameter = DonationItemListUIComposer.Parameter(postDonationId: donationId)
        let actions = DonationItemListUIComposer.Action(selection: navigateToDonationItemDetailViewController)
        let controller = DonationItemListUIComposer.composeWith(
            role: role,
            loader: makeDonationItemListLoader,
            imageLoader: ImageResourceLoader(publisher: makeImageLoader),
            parameter: parameter,
            actions: actions
        )
        return controller
    }
    
    func makeDonationItemDetailViewController(
        id: String, 
        role: DonationItemRole
    ) -> UIViewController {
        let parameter = DonationItemDetailUIComposer.Parameter(id: id, role: role)
        let actions = DonationItemDetailUIComposer.Actions(didTapDonateButton: navigateToDonationItemCheckout)
        let controller = DonationItemDetailUIComposer.composeWith(
            loader: makeDonationItemDetailLoader,
            imageLoader: ImageResourceLoader(publisher: makeImageLoader),
            parameter: parameter,
            actions: actions
        )
        return controller
    }
    
    func makeDonationItemCheckoutViewController(
        viewModel: DonationItemDetailViewModel,
        quantity: Int
    ) -> UIViewController {
        let param = DonationItemCheckoutUIComposer.Parameter(viewModel: viewModel, quantity: quantity)
        let callback = DonationItemCheckoutUIComposer.Callback(showTransactionList: navigateToTransaction)
        let controller = DonationItemCheckoutUIComposer.composeWith(
            loader: DonationItemCheckoutLoader(publisher: makeDonationItemCheckoutLoader),
            imageLoader: ImageResourceLoader(publisher: makeImageLoader),
            parameter: param,
            callback: callback
        )
        return controller
    }
    
    func makeDonationItemPaymentViewController(orderId: String) -> UIViewController {
        let action = DonationItemPaymentUIComposer.Action(showInitiatorProfile: navigateToProfileViewController)
        let parameter = DonationItemPaymentUIComposer.Parameter(orderId: orderId)
        let controller = DonationItemPaymentUIComposer.composeWith(
            loader: makeDonationItemPaymentLoader,
            imageLoader: ImageResourceLoader(publisher: makeImageLoader),
            parameter: parameter, 
            action: action
        )
        return controller
    }
}
