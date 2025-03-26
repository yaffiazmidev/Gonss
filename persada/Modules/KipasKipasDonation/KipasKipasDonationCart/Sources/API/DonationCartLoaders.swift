//
//  DonationCartLoaders.swift
//  KipasKipasDonationCart
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/02/24.
//

import Combine
import KipasKipasNetworking

public typealias DonationCartOrderLoader = AnyPublisher<Root<DonationCartOrder>, Error>
public typealias DonationCartOrderExistLoader = AnyPublisher<Root<DonationCartOrderExist>, Error>
public typealias DonationCartOrderDetailLoader = AnyPublisher<Root<DonationCartOrderDetail>, Error>
