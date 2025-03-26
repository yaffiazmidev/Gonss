import Foundation

struct RemoteReasonData: Codable {
    let data: [Reason]?
    
    struct Reason: Codable {
        let id, value, type: String?
    }
}

final class RemoteReasonDataMapper {
    
    private init() {}
    
    private static var OK_200: Int {
        return 200
    }
    
    private static var FORBIDDEN_401: Int {
        return 401
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteReasonData {
        guard response.statusCode == OK_200, let page = try? JSONDecoder().decode(RemoteReasonData.self, from: data) else {
            if response.statusCode == FORBIDDEN_401 {
                throw RemoteReportReasonLoader.Error.notAuthenticated
            } else {
                throw RemoteReportReasonLoader.Error.invalidResponse
            }
        }
        
        return page
    }
}
