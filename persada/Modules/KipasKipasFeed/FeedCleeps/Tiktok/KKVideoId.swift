//
//  KKVideoId.swift
//  FeedCleeps
//
//  Created by koanba on 25/04/23.
//

import Foundation
public class KKVideoId {
    
    public init(){}
    
    public func getId(urlString : String?) -> String {
        var videoId = ""
        
        
        if let urlPath = urlString {
            if urlPath != "" {
                
                if(urlPath.contains("myqcloud")){
                    return self.getIdTencent(urlString: urlPath)
                }

                let pathOfUrl = urlPath.components(separatedBy: "/")
                
                var videoIdWithMp4 = ""
                
                var is576Link = pathOfUrl[pathOfUrl.count-1]
                if(is576Link.contains("p.mp4")){
                    videoIdWithMp4 = pathOfUrl[pathOfUrl.count-2]
                } else {
                    videoIdWithMp4 = pathOfUrl[pathOfUrl.count-1]
                }
                
                videoId = videoIdWithMp4.replacingOccurrences(of: ".mp4", with: "", options: [.caseInsensitive])
            }
        }
        print("KKVideoId: ", urlString)
        return videoId

    }

    public func getId(url : URL?) -> String {
        var videoId = ""
        
        if(url != nil){
            if(url?.absoluteString != ""){
                videoId = self.getId(urlString: url?.absoluteString)
            }
        }
        
        return videoId
    }
    
    public func getId(feed : Feed?) -> String {
        var videoId = ""
        
        if(feed != nil){
            
            if let url = feed?.post?.medias?.first?.vodUrl {
                guard !url.isEmpty else { return videoId }
                videoId = self.getIdTencent(urlString: url)
            }
            
        }
        
        return videoId
    }

    func getIdTencent(urlString : String?) -> String {
        // https://1316940742.vod2.myqcloud.com/ae9df7c5vodtranssgp1316940742/4ea2cd9b5576678019774753582/v.f100800.mp4
        // https://1316940742.vod2.myqcloud.com/ae9df7c5vodtranssgp1316940742/7e75d1625576678021026633352/adp.1449774.m3u8
        if let pathOfUrl = urlString?.components(separatedBy: "/") {
            // 0 = "https:",
            // 1 = "",
            // 2 = "1316940742.vod2.myqcloud.com"
            // 3 = "ae9df7c5vodtranssgp1316940742"
            // 4 = "cb2f608d5576678019745256410"
            // 5 = "v.f100800.mp4"

            //print("getIdTencent", pathOfUrl)
            guard pathOfUrl.count > 5 else { return "ID-NOT-FOUND" }
 
            if(pathOfUrl[guard: 5]?.lowercased().contains(".mp4") == true){
                return ("4TAG-" + String(pathOfUrl[4].suffix(5)))
            }

            if(pathOfUrl[guard: 5]?.lowercased().contains(".m3u8") == true){
                return ("HTAG-" + String(pathOfUrl[4].suffix(5)))
            }

            
        }

        return "NOT-TENCENT"
    }
}

extension Array {
    subscript (guard index: Index) -> Element? {
        0 <= index && index < count ? self[index] : nil
    }
}
