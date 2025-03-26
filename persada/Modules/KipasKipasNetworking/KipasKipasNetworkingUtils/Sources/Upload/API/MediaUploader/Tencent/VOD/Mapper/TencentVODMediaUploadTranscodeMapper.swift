//
//  TencentVODMediaUploadTranscodeMapper.swift
//  KipasKipasNetworkingUtils
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/11/23.
//

import Foundation
import KipasKipasNetworking

final class TencentVODMediaUploadTranscodeMapper {
    
    private struct Root: Decodable {
        let Response: TranscodeResponse
    }
    
    private struct TranscodeResponse: Decodable {
        let MediaProcessResultSet: [TranscodeMediaProcessResultSet]
        let RequestId: String
    }
    
    private struct TranscodeMediaProcessResultSet: Decodable {
        let FileId, Status, TaskId: String
    }
    
    private struct ErrorResponse: Decodable {
        let error: String
    }
    
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> Bool {
        print("**@@ mapper response \(String(describing: String(data: data, encoding: .utf8)))")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard response.isOK, let _ = try? decoder.decode(Root.self, from: data) else {
            
            if let error = try? decoder.decode(ErrorResponse.self, from: data) {
                throw KKNetworkError.responseFailure(KKErrorNetworkResponse(code: "\(response.statusCode)", message: error.error))
            }
            
            throw KKNetworkError.invalidData
        }
        
        return true
    }
}
