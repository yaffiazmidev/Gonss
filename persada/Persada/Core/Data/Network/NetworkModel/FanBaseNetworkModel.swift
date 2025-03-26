//
//  FanBaseNetworkModel.swift
//  Persada
//
//  Created by Muhammad Noor on 09/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class FanBaseNetworkModel: NetworkModel {

    func fetchFanBase(_ request: FanBaseEndpoint, _ completion: @escaping (ResultData<FanbaseArray>) -> Void) {

        let urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))

        let encodeRequestUrl = urlRequest.encode(with: request.parameter)

        requestData(encodeRequestUrl, completion)
    }
}
