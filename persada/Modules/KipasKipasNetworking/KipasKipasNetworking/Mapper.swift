import Foundation

public struct EmptyData: Codable {
    public let code, message: String
}

public struct Root<Response: Codable>: Codable {
    public let code, message: String
    public let data: Response
}

public final class Mapper<Response: Codable> {
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Response {
        guard response.statusCode.isOK() else {
            guard let error = decode(KKErrorNetworkRemoteResponse.self, from: data) else {
                let description = decode(KKErrorDescription.self, from: data)
                throw KKNetworkError.invalidDataWith(description: description, data: data)
            }
            throw KKNetworkError.responseFailure(.fromRemote(error))
        }
        
        guard let response = decode(Response.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return response
    }
    
    private static func decode<T: Decodable>(_ response: T.Type, from data: Data) -> T? {
        return try? JSONDecoder().decode(response, from: data)
    }
}


public struct MapperError {
    
    public static func map(_ error: Error) -> KKErrorNetworkResponse {
        
        let defaultError = KKErrorNetworkResponse(code: "9999", message: "Terjadi kesalahan")
        
        guard let mappedError = error as? KKNetworkError else {
            return defaultError
        }

        switch mappedError {
        case let .responseFailure(response):
            return response
        
        case let .invalidDataWith(description, data):
            return KKErrorNetworkResponse(
                code: description?.code ?? "0000",
                message: description?.message ?? "Invalid data",
                data: data
            )
            
        default:
            return defaultError
        }
    }
}

fileprivate extension Int {
    func isOK() -> Bool {
        return (200...299).contains(self)
    }
}
