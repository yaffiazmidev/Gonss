//
//  SharedTestHelpers.swift
//  KipasKipasNewsTests
//
//  Created by PT.Koanba on 16/03/22.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyDate() -> (millis: Int, date: Date) {
    let millis = 1646904304466
    let date = Date(timeIntervalSince1970: TimeInterval(millis))
    return (millis, date)
}
