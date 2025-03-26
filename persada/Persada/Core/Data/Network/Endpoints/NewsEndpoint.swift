//
//  NewsEndpoint.swift
//  KipasKipas
//
//  Created by movan on 24/11/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum NewsEndpoint {
    case newsAllCategory(page: Int)
    case newsAllCategoryPublic(page: Int)
    case newsCategory
    case staticNewsCategory
    case searchNews(title: String, page: Int)
    case news(id: String, page: Int)
    case staticNews(id: String, page: Int)
    case newsCategoryPublic
    case searchNewsPublic(title: String, page: Int)
    case newsPublic(id: String, page: Int)
}

extension NewsEndpoint: EndpointType {
    var baseUrl: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .staticNews(let id, _):
            return "/statics/feeds/post/news"
        case .news(let id, _):
            return "/news/\(id)"
        case .newsCategory:
            return "/news/category"
        case .staticNewsCategory:
            return "/statics/news/category"
        case .searchNews(_):
            return "/news/search"
        case .newsPublic(let id, _):
            return "/public/news/\(id)"
        case .newsCategoryPublic:
            return "/public/news/category"
        case .searchNewsPublic:
            return "/public/news/search"
        case .newsAllCategory:
            return "/feeds/post/news"
        case .newsAllCategoryPublic:
            return "/public/feeds/post/news"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var header: [String : Any] {
        return [
            "Authorization" : "Bearer \(getToken() ?? "")",
            "Content-Type":"application/json",
        ]
    }
    
    var parameter: [String : Any] {
        switch self {
        case .news(_, let page), .newsPublic(_, let page), .staticNews(_, let page):
            return [
                "size" : "10",
                "page" : "\(page)",
            ]
        case .searchNews(let title, let page):
            return [
                "title" : "\(title)",
                "size" : "10",
                "page" : "\(page)",
            ]
        case .searchNewsPublic(let title, let page):
            return [
                "title" : "\(title)",
                "size" : "10",
                "page" : "\(page)",
            ]
        case .newsAllCategory(let page), .newsAllCategoryPublic(let page):
            return [
                "page" : "\(page)",
                //                "direction": "DESC",
                //                "sort": "id",
                "size": "10"
            ]
        case .newsCategoryPublic, .newsCategory, .staticNewsCategory:
            return [:]
        }
    }
}
