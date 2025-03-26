//
//  TencentVODMediaUploadSignatureMapper.swift
//  KipasKipasNetworkingUtils
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/11/23.
//

import Foundation
import KipasKipasNetworking

final class TencentVODMediaUploadSignatureMapper {
    
    private struct Root: Decodable {
        let data: SignatureData
        
        var item: String { data.signature }
    }
    
    private struct SignatureData: Decodable {
        let signature: String
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> String {
        print("**@@ mapper response \(String(describing: String(data: data, encoding: .utf8)))")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard response.isOK, let root = try? decoder.decode(Root.self, from: data) else {
            
            if let error = try? decoder.decode(KKErrorNetworkRemoteResponse.self, from: data) {
                throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
            }
            
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
