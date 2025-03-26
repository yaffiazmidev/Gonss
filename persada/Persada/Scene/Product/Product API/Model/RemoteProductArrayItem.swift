//
//  RemoteProductListItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteProductArrayItem: Codable {
    let code, message: String?
    let data: RemoteProductArrayItemData?
}

struct RemoteProductArrayItemData: Codable {
    let content: [RemoteProductItem]?
    let pageable: RemoteProductPageable?
    let totalElements: Int?
    let totalPages: Int?
    let last: Bool?
    let sort: RemoteProductSort?
    let first: Bool?
    let numberOfElements: Int?
    let size: Int?
    let number: Int?
    let empty: Bool?
}
