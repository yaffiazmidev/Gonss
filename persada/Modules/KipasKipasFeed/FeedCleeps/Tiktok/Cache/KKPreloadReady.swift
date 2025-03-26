//
//  KKPreloadReady.swift
//  FeedCleeps
//
//  Created by koanba on 21/04/23.
//

import Foundation

class KKPreloadReady {
    
    public static let instance = KKPreloadReady()
    
    let LOG_ID = "==KKPreloadReady=="

    var urlAndCodes:[(videoId: String, code: String)] = []
    
    
    func appendReady(urlString: String, code: String) {

        if(urlString != ""){
            let videoId = self.getVideoId(urlPath: urlString)
            
            self.urlAndCodes.append((videoId:videoId, code: code ))
            
            //print(self.LOG_ID, "Proc append Ready", code, "urlString:", urlString, "videoId:", videoId)
        }
    }
    
    
    func isReady(feed: Feed) -> Bool {
        
        
        let feedUrl = self.getVideoId(urlPath: feed.post?.medias?.first?.url)
                
        let videoId = self.getVideoId(urlPath: feedUrl)
        
        let isReady = self.urlAndCodes.filter{ $0.videoId == videoId }.first
        
        return isReady != nil
    }
    
    
    func getVideoId(urlPath: String?) -> String {
        var videoId = ""
        if let urlPath = urlPath {
            if urlPath != "" && urlPath != "null" {
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
        return videoId
    }

    
    func getVideoId(feed: Feed?) -> String {

        let videoId = self.getVideoId(urlPath: feed?.post?.medias?.first?.url)

        return videoId
    }

}

