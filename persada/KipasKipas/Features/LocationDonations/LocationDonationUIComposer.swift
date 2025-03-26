import Foundation
import KipasKipasShared
import KipasKipasNetworking

final class LocationDonationUIComposer {
    private init() {}
    
    static func locationDonation(
        loader: LocationDonationLoader,
        selectByProvinceId: @escaping (LocationDonationItem) -> Void,
        selectByCurrentLocation: @escaping (_ long: Double?, _ lat: Double?) -> Void,
        selectAllLocation: @escaping () -> Void
    ) -> LocationDonationController {
        
        let adapter = LocationDonationPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: loader))
        let controller = LocationDonationController(
            delegate: adapter,
            selectByCurrentLocation: selectByCurrentLocation,
            selectByProvinceId: selectByProvinceId,
            selectAllLocation: selectAllLocation
        )
        
        adapter.presenter = LocationDonationPresenter(
            view: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
