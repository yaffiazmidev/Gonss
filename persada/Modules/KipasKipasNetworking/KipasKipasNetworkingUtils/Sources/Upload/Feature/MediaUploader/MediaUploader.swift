//
//  AlibabaUploader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 12/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import Combine

public protocol MediaUploader {
    typealias Result = Swift.Result<MediaUploaderResult, Error>
    
    func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void)
    
    func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void, uploadProgress: @escaping (Double) -> Void)
}


public extension MediaUploader {
    typealias Publisher = AnyPublisher<MediaUploaderResult, Error>
    
    func upload(request: MediaUploaderRequestable) -> Publisher {
         
        return Deferred {
            Future { completion in
                self.upload(request: request, completion: completion)
            }
        }
        .eraseToAnyPublisher()
    }
}
