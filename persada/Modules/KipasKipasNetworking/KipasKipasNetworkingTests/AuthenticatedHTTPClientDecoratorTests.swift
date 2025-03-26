//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  KipasKipasNetworkingTests
//
//  Created by PT.Koanba on 04/04/22.
//

import XCTest
import KipasKipasNetworking

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test_request_withSuccessfulTokenRequest_signsRequestWithValidToken() {
        let validToken = anyToken().local
        let (client, _, sut, store) = makeSUT(token: validToken)
        let unsignedRequest = anyRequest()
        let token = store.retrieve()!
        
        _ = sut.request(from: unsignedRequest) { _ in }
        
        let signedRequest = sign(unsignedRequest, with: token.accessToken)
        XCTAssertEqual(client.requests, [signedRequest])
    }
    
    func test_request_withSuccessfulTokenRequest_completeWithDecorateeResult() throws {
        let values = (anyData(), httpURLRequest(with: 200))
        let expiredToken = LocalTokenItem(accessToken: "expiredToken", refreshToken: "expiredToken", expiresIn: -86400)
        let validToken = anyToken().local
        let client = HTTPClientSpy()
        let store = TokenStoreStub(stubbedToken: expiredToken)
        let loader = TokenLoaderStub(stubbedToken: validToken)
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, cache: store, loader: loader)
        let unsignedRequest = URLRequest(url: anyURL())
        
        var receivedResult: HTTPClient.Result?
        _ = sut.request(from: unsignedRequest) { receivedResult = $0 }
        
        client.complete(with: values)
        
        let receivedValues = try XCTUnwrap(receivedResult).get()
        XCTAssertEqual(receivedValues.0, values.0)
        XCTAssertEqual(receivedValues.1, values.1)
        XCTAssertNoThrow(try receivedResult?.get())
    }
    
    func test_request_withFailedTokenRequest_fails() {
        let validToken = anyToken().local
        let client = HTTPClientSpy()
        let store = TokenStoreStub(stubbedToken: validToken)
        let loader = TokenLoaderStub(stubbedError: anyNSError())
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, cache: store, loader: loader)
                
        var receivedResult: HTTPClient.Result?
        _ = sut.request(from: URLRequest(url: anyURL())) { receivedResult = $0 }
        
        XCTAssertEqual(client.requests, [])
        XCTAssertThrowsError(try receivedResult?.get())
    }
    
    func test_request_withNilRefreshTokenReturnError(){
        let validToken = anyToken().local
        let client = HTTPClientSpy()
        let store = TokenStoreStub(stubbedToken: nil)
        let loader = TokenLoaderStub(stubbedToken: validToken)
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, cache: store, loader: loader)
        let unsignedRequest = URLRequest(url: anyURL())
        
        var receivedResult: HTTPClient.Result?
        _ = sut.request(from: unsignedRequest) { receivedResult = $0 }
        
        XCTAssertEqual(client.requests, [])
        XCTAssertThrowsError(try receivedResult?.get())
    }
    
    func test_request_withExpiredToken_requestLoadFromNetwork_returnSuccess() throws {
        let values = (anyData(), httpURLRequest(with: 200))
        let expiredToken = LocalTokenItem(accessToken: "expiredToken", refreshToken: "expiredToken", expiresIn: -86400)
        let validToken = anyToken().local
        let client = HTTPClientSpy()
        let store = TokenStoreStub(stubbedToken: expiredToken)
        let loader = TokenLoaderSpy()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, cache: store, loader: loader)
        let unsignedRequest = URLRequest(url: anyURL())
        
        var receivedResult: HTTPClient.Result?
        _ = sut.request(from: unsignedRequest) { receivedResult = $0 }
        
        loader.complete(with: TokenItem(accessToken: validToken.accessToken, refreshToken: validToken.refreshToken, expiresIn: validToken.expiresIn))
        
        client.complete(with: values)
        
        let signedRequest = sign(unsignedRequest, with: validToken.accessToken)
        XCTAssertEqual(client.requests, [signedRequest])
        
        let receivedValues = try XCTUnwrap(receivedResult).get()
        XCTAssertEqual(receivedValues.0, values.0)
        XCTAssertEqual(receivedValues.1, values.1)
        
        XCTAssertNoThrow(try receivedResult?.get())
    }
    
    func test_request_withExpiredToken_requestLoadFromNetwork_fails() throws {
        let expiredToken = LocalTokenItem(accessToken: "expiredToken", refreshToken: "expiredToken", expiresIn: -86400)
        let client = HTTPClientSpy()
        let store = TokenStoreStub(stubbedToken: expiredToken)
        let loader = TokenLoaderSpy()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, cache: store, loader: loader)
        let unsignedRequest = URLRequest(url: anyURL())
        
        var receivedResult: HTTPClient.Result?
        _ = sut.request(from: unsignedRequest) { receivedResult = $0 }
        
        loader.complete(with: anyNSError())
        
        XCTAssertEqual(client.requests, [])
        XCTAssertThrowsError(try receivedResult?.get())
    }
    
    func test_request_multipleTimes_reuseRunningTokenRequest() {
        let validToken = anyToken().local
        let client = HTTPClientSpy()
        let store = TokenStoreStub(stubbedToken: validToken)
        let loader = TokenLoaderSpy()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, cache: store, loader: loader)
        let request = URLRequest(url: anyURL())
        
        XCTAssertEqual(loader.messages.count, 0)
        
        _ = sut.request(from: request) { _ in }
        _ = sut.request(from: request) { _ in }
        
        XCTAssertEqual(loader.messages.count, 1)
       
        loader.complete(with: anyNSError())
        _ = sut.request(from: request) { _ in }
        
        XCTAssertEqual(loader.messages.count, 2)
    }
    
    func test_request_multipleTimes_completesWithRespectiveClientDecorateeResult() throws {
        let validToken = anyToken().local
        let client = HTTPClientSpy()
        let store = TokenStoreStub(stubbedToken: validToken)
        let loader = TokenLoaderSpy()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, cache: store, loader: loader)
        let request = URLRequest(url: anyURL())
        
        var result1: HTTPClient.Result?
        _ = sut.request(from: request) { result1 = $0 }
        
        var result2: HTTPClient.Result?
        _ = sut.request(from: request) { result2 = $0 }
        
        loader.complete(with: anyToken().item)
        
        let values = (anyData(), httpURLRequest(with: 200))
        client.complete(with: values, at: 0)
        
        let receivedValues = try XCTUnwrap(result1).get()
        XCTAssertEqual(receivedValues.0, values.0)
        XCTAssertEqual(receivedValues.1, values.1)
        
        client.complete(with: anyNSError(), at: 1)
        XCTAssertThrowsError(try result2?.get())
    }
    
    // - MARK: Helpers
    
    private func makeSUT(token: LocalTokenItem = anyToken().local, file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, loader: TokenLoaderStub, sut: AuthenticatedHTTPClientDecorator, store: TokenStoreStub) {
        let client = HTTPClientSpy()
        let store = TokenStoreStub(stubbedToken: token)
        let loader = TokenLoaderStub(stubbedToken: token)
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, cache: store, loader: loader)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (client, loader, sut, store)
    }
    
    func error401() -> Error {
        return NSError(domain: "any error", code: 401, userInfo: nil)
    }
    
    func anyRequest() -> URLRequest {
        return URLRequest(url: anyURL())
    }
    
    func httpURLRequest(with statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    func sign(_ request: URLRequest, with token: String) -> URLRequest {
        var signedRequest = request
        signedRequest.setValue("application/json", forHTTPHeaderField:"Content-Type")
        signedRequest.setValue("Bearer \(token)", forHTTPHeaderField:"Authorization")
        return signedRequest
    }
    
    private class TokenLoaderStub: TokenLoader {
        
        private let result: TokenLoader.Result
        
        var token: TokenItem? {
            (try? result.get()) ?? nil
        }
        
        init(stubbedToken: LocalTokenItem = invalidToken().local) {
            self.result = .success(TokenItem(accessToken: stubbedToken.accessToken, refreshToken: stubbedToken.refreshToken, expiresIn: stubbedToken.expiresIn))
        }
        
        init(stubbedError: Error) {
            self.result = .failure(stubbedError)
        }
        
        func load(request: TokenRequest, completion: @escaping (TokenLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    private class TokenLoaderSpy: TokenLoader {
        var messages = [(TokenLoader.Result) -> Void]()
        
        
        func load(request: TokenRequest, completion: @escaping (TokenLoader.Result) -> Void) {
            messages.append(completion)
        }
        
        func complete(with token: TokenItem, at index: Int = 0) {
            messages[index](.success(token))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index](.failure(error))
        }
    }
    
    private class TokenStoreStub: TokenStore {
        
        private let token: LocalTokenItem?
        
        init(stubbedToken: LocalTokenItem?) {
            self.token = stubbedToken
        }
        
        func insert(_ token: LocalTokenItem, completion: @escaping InsertionCompletions) {}
        
        func retrieve() -> LocalTokenItem? {
            return token ?? nil
        }
    }
}


func anyToken() -> (local: LocalTokenItem, item: TokenItem) {
    return (local: LocalTokenItem(accessToken: "anyToken", refreshToken: "anyToken", expiresIn: notExpiredDateInSecond()), item: TokenItem(accessToken: "anyToken", refreshToken: "anyToken", expiresIn: notExpiredDateInSecond()))
}

func invalidToken() -> (local: LocalTokenItem, item: TokenItem) {
    return (local: LocalTokenItem(accessToken: "invalidToken", refreshToken: "invalidToken", expiresIn: notExpiredDateInSecond()), item: TokenItem(accessToken: "invalidToken", refreshToken: "invalidToken", expiresIn: notExpiredDateInSecond()))
}

func notExpiredDateInSecond() -> Int {
    return Int(Date().timeIntervalSinceNow + 1.0)
}

extension Date {
    func minusTokenCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 1
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
