import Foundation

final class LocationDonationPresenter {
    
    private let view: LocationDonationView
    private let loadingView: LocationDonationLoadingView
    
    init(
        view: LocationDonationView,
        loadingView: LocationDonationLoadingView
    ) {
        self.view = view
        self.loadingView = loadingView
    }
    
    func didStartLoadingGetLocationDonations() {
        loadingView.display(.init(isLoading: true))
    }
    
    func didFinishLoadingGetLocationDonations(with items: [LocationDonationItem]) {
        view.display(.init(items: items.asLocations))
        loadingView.display(.init(isLoading: false))
    }
    
    func didFinishLoadingGetLocationDonations(with error: Error) {
        loadingView.display(.init(isLoading: false))
    }
}

extension LocationDonationItem {
    var isAllLocation: Bool {
        code == "ALL"
    }
    
    var isCurrentLocation: Bool {
        code == "CURRENT"
    }
}

private extension Array where Element == LocationDonationItem {
    var asLocations: [Element] {
        let staticItem = [
            LocationDonationItem(id: "0000", name: "SEMUA LOKASI", code: "ALL"),
            LocationDonationItem(id: "1111", name: "GUNAKAN LOKASI SAAT INI", code: "CURRENT")
        ]
        return staticItem + self
    }
}
