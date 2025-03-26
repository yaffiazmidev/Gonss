import XCTest
@testable import KipasKipasImage

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        ImageURLSession.clearSession()
        ImageURLSession.observe()
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        ImageDownloadSettings.requestSettings = ImageRequestSettings()
    }
    
    func test_getFromURL_performsGETRequestWithURL() async throws {
        let url = anyURL()
        let request = URLRequest(url: url)
        
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (anyData(), anyHTTPURLResponse())
        }
        
        try await makeSUT().request(from: request)
        
        XCTAssertNotNil(capturedRequest)
        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertEqual(capturedRequest?.url, url)
    }
    
    
    func test_cancelTask_cancelsURLRequest() async throws {
        let url = anyURL()
        let request = URLRequest(url: url)
        
        let task = Task {
            do {
                let (_, response) = try await makeSUT().request(from: request)
                XCTFail("Expected a cancellation error but got \(response) instead")
            } catch {
                let error = error as NSError?
                XCTAssertEqual(error?.domain, "Swift.CancellationError")
            }
        }
        
        task.cancel()
        
        _ = await task.value
    }
    
    func test_getFromURL_failsOnRequestError() async throws {
        let url = anyURL()
        let request = URLRequest(url: url)
        let requestError = anyNSError()
        
        MockURLProtocol.requestHandler = { _ in
            throw requestError
        }
        
        do {
            let (_, response) = try await makeSUT().request(from: request)
            XCTFail("Expected an error but got \(response) instead")
        } catch(let receivedError as NSError?) {
            XCTAssertEqual(requestError.code, receivedError?.code)
            XCTAssertEqual(requestError.domain, receivedError?.domain)
        }
    }
    
    func test_getFromURL_receiveNon200StatusCode_returnsError() async throws {
        let url = anyURL()
        let request = URLRequest(url: url)
        
        MockURLProtocol.requestHandler = { _ in
            return (anyData(), anyHTTPURLResponse(statusCode: 500))
        }
        
        var capturedError: Error?
        do {
            let (_, response) = try await makeSUT().request(from: request)
            XCTFail("Should get an error but got response \(response) instead")
        } catch {
            capturedError = error
        }
        
        XCTAssertNotNil(capturedError)
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() async throws {
        let url = anyURL()
        let request = URLRequest(url: url)
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        MockURLProtocol.requestHandler = { _ in
            return (data, response)
        }
        
        do {
            let (receivedData, receivedResponse) = try await makeSUT().request(from: request)
            XCTAssertEqual(receivedData, data)
            XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            XCTAssertEqual(receivedResponse.url, response.url)
        } catch {
            XCTFail("Expected a success response but got \(error) instead")
        }
    }
    
    func test_getFromURL_failsOnTimeout() async throws {
        let url = anyURL()
        let request = URLRequest(url: url)
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        ImageDownloadSettings.requestSettings.requestTimeoutSeconds = 0.01
        
        MockURLProtocol.requestHandler = { _ in
            return (data, response)
        }
        
        do {
            let (_, receivedResponse) = try await self.makeSUT(isUsingMock: false).request(from: request)
            XCTFail("Expected a timeout error but got \(receivedResponse) instead")
        } catch(let error as NSError) {
            XCTAssertEqual(error.code, NSURLErrorTimedOut)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(
        isUsingMock: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ImageHTTPClient {
        
        let config = ImageURLSessionConfiguration.default
        
        if isUsingMock {
            config.protocolClasses = [MockURLProtocol.self]
        }
        
        let sut = ImageHTTPClientFactory.create(with: config)
        
        XCTAssertTrue(sut is URLSessionHTTPClient)
        trackForMemoryLeaks(sut as AnyObject, file: file, line: line)
        
        return sut
    }
}
