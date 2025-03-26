//
//  OSSClientFactory.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import AliyunOSSiOS

class OSSClientFactory{
    private init() {}
    
    class Alibaba {
        private init() {}
        
        static func create(usePublic: Bool) -> MediaUploader {
            let client = AlibabaOSSMediaUploader(baseUrl: usePublic ? UploadConstants.Alibaba.Endpoint.public : UploadConstants.Alibaba.Endpoint.internal)
            let loader = STSTokenLoaderFactory.create()
            return AuthenticatedMediaUploadClientDecorator(keystore: "alibaba_oss_sts_token_\(usePublic ? "internal" : "public")", decoratee: client, loader: loader)
        }
    }
    
}
