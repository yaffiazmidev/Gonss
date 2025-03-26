//
//  NetworkErrorLogger.swift
//  KipasKipasShared
//
//  Created by DENAZMI on 01/12/22.
//

import Foundation

public protocol INetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

public final class NetworkErrorLogger: INetworkErrorLogger {
    public init() { }

    public func log(request: URLRequest) {
        print("\n\n======================================================================")
        print("REQUEST : \(request.httpMethod!) \(request.url!)")
        print("HEADERS : \(request.allHTTPHeaderFields!)")
        if let httpBody = request.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            printIfDebug("BODY    : \(String(describing: result))")
        } else if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            printIfDebug("BODY    : \(String(describing: resultString))")
        }
        
    }

    public func log(responseData data: Data?, response: URLResponse?) {
        if let response = response as? HTTPURLResponse {
            print("STATUS CODE : \(response.statusCode)")
            print("=================================================")
        }
        
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            //printIfDebug("RESPONSE DATA: \(String(describing: dataDict))")
            print("=================================================")
        }
    }

    public func log(error: Error) {
        printIfDebug("\(error)")
    }
}

func printIfDebug(_ string: String) {
    #if DEBUG || ProdDebug || STAGING
    print(string)
    #endif
}
