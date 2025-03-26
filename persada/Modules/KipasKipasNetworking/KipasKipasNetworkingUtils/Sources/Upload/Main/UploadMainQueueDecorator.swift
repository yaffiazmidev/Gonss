//
//  UploadMainQueueDecorator.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

extension MainQueueDispatchDecorator: MediaUploader where T == MediaUploader {
    public func upload(request: MediaUploaderRequestable, completion: @escaping (MediaUploader.Result) -> Void) {
        decoratee.upload(request: request) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
    
    public func upload(request: MediaUploaderRequestable, completion: @escaping (MediaUploader.Result) -> Void, uploadProgress: @escaping (Double) -> Void) {
        decoratee.upload(request: request) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        } uploadProgress: { [weak self] progress in
            self?.dispatch {
                uploadProgress(progress)
            }
        }
    }
}
