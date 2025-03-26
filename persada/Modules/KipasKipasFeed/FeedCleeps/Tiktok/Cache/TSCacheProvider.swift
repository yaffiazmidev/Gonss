//
//  TSCacheProvider.swift
//  KipasKipas
//
//  Created by koanba on 07/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class TSCacheProvider {
    
    static let shared = TSCacheProvider()
    
    var tSCaches = [TSCache]()
    
    private init() {
        tSCaches = []
    }
    
    

    func add(url: String) -> TSCache {
        
        var newCache = getMediaName(url: url)
        newCache.url = url
        
        let keyCache = newCache.key()

        DataCache.instance.write(string: newCache.url, forKey: keyCache)
                
        return newCache
    }
    
    func getMediaName(url: String) -> TSCache {
        
//        KKLog.shared.debug(text: "\(url) getMediaName 1")
        //print("getMediaName", url)
        
        if(url.contains(".ts")){
            let mediaNameArray =  url.split(separator: "/")
            //print("getMediaName", mediaNameArray)
            // mediaNameArray
            // 0 https:,
            // 1: asset.kipaskipas.com,
            // 2: media,
            // 3: stream,
            // 4: 1645672137491,
            // 5: 1645672137491_480p_001.ts
            
            let segmentTsArray = mediaNameArray[5].split(separator: "_")
            let segmentTs = segmentTsArray.last
                        
            return TSCache(mediaName: String(mediaNameArray[4]), segment: String(segmentTs!), url: url)
        }
        
        return TSCache(mediaName: "", segment: "", url: "")
    }
    
    func convertSegmentTo(url: String, updatedResolution: String) -> String {
        if(url.contains(".ts") && updatedResolution != "" ){
            let mediaNameArray =  url.split(separator: "/")
                        
            let segmentTsArray = mediaNameArray[5].split(separator: "_")
            let segmentTs = segmentTsArray.last!
            
            let urlHeader = mediaNameArray[0] + "//" +
                mediaNameArray[1] + "/" +
                mediaNameArray[2] + "/" +
                mediaNameArray[3] + "/" +
                mediaNameArray[4]
            
            let urlTail = segmentTsArray[0] + "_" + updatedResolution + "_" + segmentTs
            let urlNew = urlHeader + "/" + urlTail
            
            //print("****** convertSegmentTo urlNew", urlNew)
            
            return String(urlNew)
        }
        
        return url
    }

    func find(url: String, completionHasCache:  @escaping (Bool, TSCache) -> Void) {
        
        let urlToFind = self.getMediaName(url: url)
        
        if(urlToFind.mediaName != ""){

            let key = urlToFind.key()
            let cachedUrl = DataCache.instance.readString(forKey: key)
            
            //print("=== find key, \(key) ")
            
            if(cachedUrl != nil){
                print("=== okesips zss find \(url), found")
                completionHasCache(true, TSCache(mediaName: urlToFind.mediaName, segment: urlToFind.segment, url: cachedUrl!))
            } else {
                print("=== okesips zsss find \(url), new, gonna add")
                completionHasCache(false, TSCache(mediaName: urlToFind.mediaName, segment: urlToFind.segment, url: url))
            }
        } else {
            print("=== okesips zsss find \(url), not asset URL")
            completionHasCache(false, TSCache(mediaName: "", segment: "", url: url))
        }
    }
    
    func delete(url: String ){
        var newCache = getMediaName(url: url)
        DataCache.instance.clean(byKey: newCache.key())
    }
    
    
    func setPlaylistMax(mediaName: String, playlists: String) {
        //print("======= setPlaylistMax", mediaName, playlists)
        let key = "MAX"+mediaName
        DataCache.instance.write(string: playlists, forKey: key)
    }
    
    func getPlaylistMax(mediaName: String) -> String {
        let key = "MAX"+mediaName

        let maxResolution = DataCache.instance.readString(forKey: key) ?? ""
        return maxResolution
    }
    
}
