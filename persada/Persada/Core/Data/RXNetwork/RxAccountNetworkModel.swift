//
//  RxAccountNetworkModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 01/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

public final class RxAccountNetworkModel {
    private let network: Network<DefaultResponse>
    
    init(network: Network<DefaultResponse>) {
        self.network = network
    }
    
    func updateEmail(email : String) -> Observable<DefaultResponse> {
        return network.postItem(AccountEndPoint.updateEmail(email: email).path, parameters: AccountEndPoint.updateEmail(email: email).parameter, headers: AccountEndPoint.updateEmail(email: email).header)
    }
}
