//
//  FilterDonationCategoryRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 24/02/23.
//

import Foundation

protocol IFilterDonationCategoryRouter {
    func locationDonation()
}

class FilterDonationCategoryRouter: IFilterDonationCategoryRouter {
    weak var controller: FilterDonationCategoryViewController?
    
    init(controller: FilterDonationCategoryViewController?) {
        self.controller = controller
    }
    
    func locationDonation() {
        let locationFilter = LocationDonationUIFactory.create(
            selectByProvinceId: { [weak self] location in
                self?.controller?.filterByProvinceId(location)
            },
            selectByCurrentLocation: { [weak self] (long, lat) in
                self?.controller?.filterByCoordinate(longitude: long, latitude: lat)
            },
            selectAllLocation: { [weak self] in
                self?.controller?.filterByAllLocation()
            }
        )
        controller?.present(locationFilter, animated: true)
    }
}

extension FilterDonationCategoryRouter {
    static func configure(controller: FilterDonationCategoryViewController) {
        let router = FilterDonationCategoryRouter(controller: controller)
        let presenter = FilterDonationCategoryPresenter(controller: controller)
        let authNetwork = DIContainer.shared.apiDataTransferService
        let interactor = FilterDonationCategoryInteractor(presenter: presenter, network: authNetwork)
        controller.router = router
        controller.interactor = interactor
    }
}

struct FilterDonationTemporaryStore: Codable {
    var categoryId: String?
    var longitude, latitude: Double?
    var provinceId: String?
    var name: String?
}
