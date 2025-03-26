//
//  KKTencentVideoPlayerHelper.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 12/07/23.
//

import Foundation
import TXLiteAVSDK_Professional
import JWT

class KKTencentVideoPlayerHelper {
    static let instance: KKTencentVideoPlayerHelper = KKTencentVideoPlayerHelper()
    
    private let TENCENT_APP_ID = 1316940742
    
    let LOG_ID = "====KKTencentVideoPlayerHelper"
    
    let preferredResolution = 1080 * 1920
    
    private init() {
        self.setupLicense()
    }
    
    func setupLicense () {
        let licenceURL = "https://license.vod-control.com/license/v2/1316940742_1/v_cube.license";
        let licenceKey = "7e83f0cac294d0b9f53a23c96b36c388";
        TXLiveBase.setLicenceURL(licenceURL, key: licenceKey)
    }
    
    func buildVideoParam(video id: String) -> TXPlayerAuthParams{
        let param = TXPlayerAuthParams()
        param.https = true
        param.fileId  = id
        param.appId = Int32(self.TENCENT_APP_ID)
        param.sign = self.generateTokenPlayer(video: id)
        
        return param
    }
    
    func generateTokenPlayer(video id: String) -> String {
        let contentInfo = [
            "audioVideoType" : "Original",
            "imageSpriteDefinition" : 10,
        ] as [String : Any]
        
        let urlAccessInfo = [
            "scheme": "HTTPS",
            "domain": "\(self.TENCENT_APP_ID).vod2.myqcloud.com"
        ]
        
        let currentTimeStamp = Int(Date().timeIntervalSince1970)
        let expireTimeStamp = Int(Date().timeIntervalSince1970 + 1000)
        
        let payload = [
            "appId" : self.TENCENT_APP_ID,
            "fileId" : id,
            "contentInfo" : contentInfo,
            "currentTimeStamp" : currentTimeStamp,
            //"expireTimeStamp" : expireTimeStamp,
            "urlAccessInfo" : urlAccessInfo
        ] as [String : Any]
        
        let secret = "HmB3OjbLTCJriq1dZe5f"
        
        let token = JWT.encode(claims: payload, algorithm: .hs256(secret.data(using: .utf8)!))
        
        print(self.LOG_ID, "generated token", token, "for video id", id)
        return token
    }
    
    func videoId(from url: String) -> Substring? {
        var splitUrl = url.split(separator: "/")
        if !splitUrl.isEmpty {
            var index = splitUrl.count - 2
            if index < 0 { index = 0 }
            return splitUrl[index]
        }
        return nil
    }
}
