import XCTest
@testable import KipasKipasImage

class CachedHTTPClientDecoratorTests: XCTestCase {
        
    override func setUp() {
        ImageURLSession.clearSession()
        ImageURLSession.observe()
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        ImageDownloadSettings.requestSettings.cacheSettings = nil
        URLCache.shared.removeAllCachedResponses()
    }
    
    func test_getFromURLAndSaveToCache_returnsFromCacheOnNextRequest() async throws {
        let request = anyRequest()
        let data = anyData()
        
        let serverDate = Date(timeIntervalSinceNow: 0)
        let response = anyHTTPURLResponse(headerFields: ["Date": DateFormatter.httpHeaderFormatter.string(from: serverDate)])
        
        ImageDownloadSettings.requestSettings.cacheSettings?.cacheExpirationTime = 10
                
        /**
         First request save to cache
         */
        MockURLProtocol.requestHandler = { _ in
            return (data, response)
        }
        
        let (receivedData, _) = try await makeSUT().request(from: request)
        XCTAssertEqual(data, receivedData)
        
        /**
         Second request load from cache
         */
        MockURLProtocol.requestHandler = { _ in
            return (anyData(value: "IMAGE2.jpg") /* request different data */, response)
        }
        
        let (receivedData2, _) = try await makeSUT().request(from: request)
        XCTAssertEqual(receivedData2, data) // Returns cached data
    }
    
    func test_getFromURLAndSaveToCache_expirationTimeIsZero_returnsFromRemoteDataOnNextRequest() async throws {
        let request = anyRequest()
        let data = anyData()
        
        let serverDate = Date(timeIntervalSinceNow: 0)
        let response = anyHTTPURLResponse(headerFields: ["Date": DateFormatter.httpHeaderFormatter.string(from: serverDate)])
        
        ImageDownloadSettings.requestSettings.cacheSettings?.cacheExpirationTime = 0
                
        /**
         First request save to cache
         */
        MockURLProtocol.requestHandler = { _ in
            return (data, response)
        }
        
        let (receivedData, _) = try await makeSUT().request(from: request)
        XCTAssertEqual(data, receivedData)
        
        /**
         Second request load from remote
         */
        MockURLProtocol.requestHandler = { _ in
            return (anyData(value: "IMAGE2.jpg") /* request different data */, response)
        }
        
        let (receivedData2, _) = try await makeSUT().request(from: request)
        XCTAssertNotEqual(receivedData2, data) // Returns new data
    }
    
    func test_getFromURLAndSaveCache_whenCacheExpired_returnsFromRemoteDataOnNextRequest() async throws {
        let request = anyRequest()
        let data = anyData()
        
        let serverDate = Date(timeIntervalSinceNow: -2000) // 2000 seconds before from now
        let response = anyHTTPURLResponse(headerFields: ["Date": DateFormatter.httpHeaderFormatter.string(from: serverDate)])
        
        ImageDownloadSettings.requestSettings.cacheSettings?.cacheExpirationTime = 10
                
        /**
         First request save to cache
         */
        MockURLProtocol.requestHandler = { _ in
            return (data, response)
        }
        
        let (receivedData, _) = try await makeSUT().request(from: request)
        XCTAssertEqual(data, receivedData)
        
        /**
         Second request load from remote
         */
        MockURLProtocol.requestHandler = { _ in
            return (anyData(value: "IMAGE2.jpg") /* request different data */, response)
        }
        
        let (receivedData2, _) = try await makeSUT().request(from: request)
        XCTAssertNotEqual(receivedData2, data) // Returns new data
    }
    
    func test_getFromURLAndSaveToCache_whenCacheDiskChanged_returnsFromRemoteDataOnNextRequest() async throws {
        let request = anyRequest()
        let data = anyData()
        
        let serverDate = Date(timeIntervalSinceNow: 0)
        let response = anyHTTPURLResponse(headerFields: ["Date": DateFormatter.httpHeaderFormatter.string(from: serverDate)])
        
        ImageDownloadSettings.requestSettings.cacheSettings?.cacheExpirationTime = 10
                
        /**
         First request save to cache
         */
        MockURLProtocol.requestHandler = { _ in
            return (data, response)
        }
        
        let (receivedData, _) = try await makeSUT().request(from: request)
        XCTAssertEqual(data, receivedData)
        
        /**
         Second request load from remote
         */
        MockURLProtocol.requestHandler = { _ in
            return (anyData(value: "IMAGE2.jpg") /* request different data */, response)
        }
        
        /// Change cache disk
        ImageDownloadSettings.requestSettings.cacheSettings?.diskPath = "SOMEWHERE"
        
        let (receivedData2, _) = try await makeSUT().request(from: request)
        XCTAssertNotEqual(receivedData2, data) // Returns new data
    }
    
    // MARK: - Helpers
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ImageHTTPClient {
        
        let config = ImageURLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        
        let sut = ImageHTTPClientFactory.create(with: config)
        
        XCTAssertTrue(sut is CachedHTTPClientDecorator)
        trackForMemoryLeaks(sut as AnyObject, file: file, line: line)
        
        return sut
    }
}
