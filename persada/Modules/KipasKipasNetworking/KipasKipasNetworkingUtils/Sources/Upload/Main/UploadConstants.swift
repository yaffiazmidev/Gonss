//
//  STSConstants.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

public class UploadConstants {
    private static var _dictionary: [String: Any]?
    private static var aes: Cryptable?
    private static let lock = NSLock()
    
    private static var dictionary: [String: Any] {
        if _dictionary == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _dictionary == nil {
                _dictionary = Bundle.main.infoDictionary!
            }
        }
        return _dictionary!
    }
    
    private init() {}
}

// MARK: - Alibaba
extension UploadConstants {
    public class Alibaba {
        private static var _stsUsername: String?
        private static var _stsPassword: String?
        
        private init() {}
        
        public class Endpoint {
            private static var _public: String?
            private static var _internal: String?
            
            private init() {}
            
            public static var `public`: String {
                if let endpoint = _public {
                    return endpoint
                }
                
                let string = dictionary["ALIBABA_ENDPOINT_PUBLIC"] as! String
                let endpoint = UploadConstants.decrypt(from: string)
                _public = endpoint
                print("**@@ endpoint public", _public ?? "null")
                return endpoint
            }
            
            public static var `internal`: String {
                if let endpoint = _internal {
                    return endpoint
                }
                
                let string = dictionary["ALIBABA_ENDPOINT_INTERNAL"] as! String
                let endpoint = UploadConstants.decrypt(from: string)
                _internal = endpoint
                print("**@@ endpoint internal", _internal ?? "null")
                return endpoint
            }
        }
        
        public static var bucketName: String {
            print("**@@ bucket name", dictionary["ALIBABA_BUCKET_NAME"] as? String ?? "null")
            return dictionary["ALIBABA_BUCKET_NAME"] as! String
        }
        
        public static var stsEndpoint: String {
            print("**@@ endpoint sts", dictionary["ALIBABA_BUCKET_NAME"] as? String ?? "null")
            return dictionary["ALIBABA_STS_ENDPOINT"] as! String
        }
        
        public static var stsUsername: String {
            if let stsUsername = _stsUsername {
                return stsUsername
            }
            
            let string = dictionary["ALIBABA_STS_USER"] as! String
            let stsUsername = UploadConstants.decrypt(from: string)
            _stsUsername = stsUsername
            print("**@@ username sts", _stsUsername ?? "null")
            return stsUsername
        }
        
        public static var stsPassword: String {
            if let stsPassword = _stsPassword {
                return stsPassword
            }
            
            let string = dictionary["ALIBABA_STS_PASS"] as! String
            let stsPassword = UploadConstants.decrypt(from: string)
            _stsPassword = stsPassword
            print("**@@ password sts", _stsPassword ?? "null")
            return stsPassword
        }
    }
}

// MARK: - Tencent
extension UploadConstants {
    public class Tencent {
        private init() {}
        
        public class COS {
            private static var _secretId: String?
            private static var _secretKey: String?
            
            private init() {}
            
            public static var endpoint: String { return dictionary["TENCENT_COS_ENDPOINT"] as! String }
            
            public static var secretId: String {
                if let secretId = _secretId {
                    return secretId
                }
                
                let string = dictionary["TENCENT_COS_SECRET_ID"] as! String
                let secretId = UploadConstants.decrypt(from: string)
                _secretId = secretId
                return secretId
            }
            
            public static var secretKey: String { 
                if let secretKey = _secretKey {
                    return secretKey
                }
                
                let string = dictionary["TENCENT_COS_SECRET_KEY"] as! String
                let secretKey = UploadConstants.decrypt(from: string)
                _secretKey = secretKey
                return secretKey
            }
            
            public static var bucketName: String { return dictionary["TENCENT_COS_BUCKET_NAME"] as! String }
            
            public static var region: String { return dictionary["TENCENT_COS_REGION"] as! String }
        }
        
        public class VOD {
            private static var _secretId: String?
            private static var _secretKey: String?
            
            private init() {}
            
            public static var secretId: String {
                if let secretId = _secretId {
                    return secretId
                }
                
                let string = dictionary["TENCENT_VOD_SECRET_ID"] as! String
                let secretId = UploadConstants.decrypt(from: string)
                _secretId = secretId
                return secretId
            }
            
            public static var secretKey: String {
                if let secretKey = _secretKey {
                    return secretKey
                }
                
                let string = dictionary["TENCENT_VOD_SECRET_KEY"] as! String
                let secretKey = UploadConstants.decrypt(from: string)
                _secretKey = secretKey
                return secretKey
            }
            
            public static var signatureEndpoint: String { return dictionary["TENCENT_VOD_SIGNATURE_ENDPOINT"] as! String }
            
            public class Transcode {
                private static var _username: String?
                private static var _password: String?
                
                private init() {}
                
                public static var endpoint: String { return dictionary["TENCENT_VOD_TRANSCODE_ENDPOINT"] as! String }
                
                public static var id: String { return dictionary["TENCENT_VOD_TRANSCODE_ID"] as! String }
                
                public static var username: String {
                    if let username = _username {
                        return username
                    }
                    
                    let string = dictionary["TENCENT_VOD_TRANSCODE_USER"] as! String
                    let username = UploadConstants.decrypt(from: string)
                    _username = username
                    return username
                }
                
                public static var password: String {
                    if let password = _secretKey {
                        return password
                    }
                    
                    let string = dictionary["TENCENT_VOD_TRANSCODE_PASS"] as! String
                    let password = UploadConstants.decrypt(from: string)
                    _password = password
                    return password
                }
            }
        }
    }
}

// MARK: - Decryptor
fileprivate extension UploadConstants {
    private static func decrypt(from string: String, count: Int = 2) -> String {
        if aes == nil {
            aes = try! AES(keyString: "com.koanba.kipaskipas.mobile.key")
        }
        
        if count <= 0 {
            return string
        }
        
        var decoded = string
        for _ in 0..<count {
            let data = Data(base64Encoded: decoded)!
            decoded = try! aes!.decrypt(data)
        }
        
        return decoded
    }
}
