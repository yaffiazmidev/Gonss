//
//  RemoteCallProfileSearchResponse.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation

struct RemoteCallProfileSearchResponse: Codable {
    
    let data: [RemoteCallProfileData]?
    let code: String?
    let message: String?
    
}
