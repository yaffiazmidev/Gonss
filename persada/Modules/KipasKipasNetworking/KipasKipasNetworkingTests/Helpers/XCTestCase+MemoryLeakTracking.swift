//
//  x.swift
//  KipasKipasNewsTests
//
//  Created by PT.Koanba on 16/03/22.
//

import XCTest

extension XCTestCase {
    
    func makeURL(_ string: String = "https://some-given-url.com", file: StaticString = #file, line: UInt = #line) -> URL {
      guard let url = URL(string: string) else {
        preconditionFailure("Could not create URL for \(string)", file: file, line: line)
      }
      return url
    }

    func makeError(_ str: String = "uh oh, something went wrong") -> NSError {
      return NSError(domain: "TEST_ERROR", code: -1, userInfo: [NSLocalizedDescriptionKey: str])
    }

    func makeData(isEmpty: Bool = false) -> Data {
      return isEmpty ? Data() : Data("any data".utf8)
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
