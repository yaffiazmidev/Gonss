//
//  ProductArchiveModel.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 22/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

enum ProductArchiveModel {

    enum Route {
        case seeDetailProductArchive(product: Product)
    }
    
    enum Response {
        case pagination(data: [Product])
        case archiveProduct(data: [Product])
        case deleteProduct(data: Product)
        case emptyArchiveProduct
        case notFoundArchiveProduct
    }
    enum ViewModel {
        case pagination(viewModel: [Product])
        case product(viewModel: [Product])
        case delete(id: String)
        case empty
        case notFound
    }

    enum Menu {
        case active, edit, delete
    }
    struct DataSource: DataSourceable {
        var id: String?
        var paramReport: (id: String, accountId: String, imageUrl: String)?
        var isLoading: Bool? = false
        var statusLike: String?
        var index: Int?
        var page: Int?
        var headerComment: CommentHeaderCellViewModel?
        var data: [Product]? = []
        
        mutating func setLoadingToggle() {
            isLoading?.toggle()
        }
    }
   
}
