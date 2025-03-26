//
//  APIManager.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Alamofire

class KKAPIManager {
    var session: Session
    
    init(session: Session = Session.default) {
        self.session = session
    }
    
    func execute(request: URLRequestConvertible) throws -> DataRequest {
        session.request(request)
    }
}
