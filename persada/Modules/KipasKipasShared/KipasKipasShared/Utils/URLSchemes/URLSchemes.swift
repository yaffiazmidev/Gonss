//
//  URLSchemes.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 15/11/23.
//

import Foundation


public protocol URLSchemesDelegate {
    func didReceive(with data: URLSchemesQuery)
}

public class URLSchemes {
    
    private static var _instance: URLSchemes?
    private static let lock = NSLock()
    
    private let identifier: String = "URLSchemes"
    private var data: URLSchemesQuery?
    
    public static var instance: URLSchemes {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = URLSchemes()
            }
        }
        return _instance!
    }
    
    public var delegate: URLSchemesDelegate?
    
    public func didBecomeActive() {
        if let query = data {
            delegate?.didReceive(with: query)
            data = nil
        }
    }
    
    public func application(open url: URL) {
        var params = Dictionary<String, String>()
        if let query = url.query {
            let pairs = query.components(separatedBy: "&")
            for pair in pairs {
                let field = pair.components(separatedBy: "=")
                if field.count == 2 {
                    if let key = field.first, let value = field.last {
                        params[key] = value
                    }
                }
            }
        }
        
        data = URLSchemesQuery(query: url.intent, data: params)
    }
}

fileprivate extension URL {
    var intent: String {
        if let arguments = absoluteString.components(separatedBy: "kipasapp://").last,
           let intent = arguments.components(separatedBy: "?").first {
            return intent
        }
        return ""
    }
}
