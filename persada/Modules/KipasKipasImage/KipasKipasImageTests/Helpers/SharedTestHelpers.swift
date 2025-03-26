import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL(path: String = "") -> URL {
    return URL(string: "http://any-url.com/" + path)!
}

func anyRequest() -> URLRequest {
    return URLRequest(url: anyURL())
}

func anyData(value: String = "any data") -> Data {
    return Data(value.utf8)
}

func anyHTTPURLResponse(
    statusCode: Int = 200,
    headerFields: [String: String] = [:]
) -> HTTPURLResponse {
    return HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: headerFields)!
}

func nonHTTPURLResponse() -> URLResponse {
    return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}
