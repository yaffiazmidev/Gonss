import Foundation

final class LocationDonationPresentationAdapter: LocationDonationViewControllerDelegate {
    
    private let loader: LocationDonationLoader
    
    var presenter: LocationDonationPresenter?
    
    init(loader: LocationDonationLoader) {
        self.loader = loader
    }
    
    func didRequestLocationDonation(request: LocationDonationRequest) {
        presenter?.didStartLoadingGetLocationDonations()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(locations):
                self.presenter?.didFinishLoadingGetLocationDonations(with: locations)
                
            case let .failure(error):
                self.presenter?.didFinishLoadingGetLocationDonations(with: error)
            }
        }
    }
}
