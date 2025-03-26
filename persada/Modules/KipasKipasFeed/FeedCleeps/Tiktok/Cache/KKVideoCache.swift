//
//  TSCache.swift
//  tiktokclone
//
//  Created by koanba on 07/02/22.
//

import AVKit

final class KKVideoCache {
    
    static let selectedVideoResolution = KKVideoResolution.P720
    static let shared = KKVideoCache()
    private init() { }
    
    let MAX_TS = 2
    
    public var priorityVideoId = ""
    
    public let SELECTED_RESOLUTION = KKVideoCache.selectedVideoResolution
    
    func cacheTsByUrl(urlString: String,  completion:  @escaping (Bool) -> ()){
//        if(DebugMode().isModule(moduleName: "square")){
//            completion(true)
//        } else {
//            
//            let urlPlaylist = self.selectPlaylist(source: urlString, toPlaylist: self.SELECTED_RESOLUTION)
//            let urlPlaylistProxy = KKWebServerFeedCleeps.shared.getUrl(url: urlPlaylist)
//
//            let urlPlaylist480 = self.selectPlaylist(source: urlString, toPlaylist: KKVideoResolution.P480)
//            let urlPlaylistProxy480 = KKWebServerFeedCleeps.shared.getUrl(url: urlPlaylist480)
//
////            print("====kkvideocache urlPlaylistProxy", urlPlaylistProxy)
////            print("====kkvideocache urlPlaylistProxy480", urlPlaylistProxy480)
//            
//            //let urlPlaylistArray = urlPlaylist.split(separator: "/")
//            //let mediaName = String(urlPlaylistArray[urlPlaylistArray.count-2])
//            //urlPlaylist    String    "https://asset.kipaskipas.com/media/stream/1643971877574/480p.m3u8"
//                        
//            //let date = NSDate(timeIntervalSince1970: Double(mediaName)!/1000)
//            //let dayTimePeriodFormatter = DateFormatter()
//            //dayTimePeriodFormatter.dateFormat = "dd MMM"
//            //let dateString = dayTimePeriodFormatter.string(from: date as Date)
//    //        print("******* media ",mediaName," create at", dateString)
//
//            
//            self.fetchMaster(urlString: urlPlaylistProxy.absoluteString, completion: { tsUrls, error in
//                if(error != nil){
//                    print("====kkvideocache fetchMaster default error", error)
//                    // maybe this video doesnt have SELECTED_RESOLUTION (eg:720p), then try get lowest (480p)
//                    //completion(false)
//                    self.fetchMaster(urlString: urlPlaylistProxy480.absoluteString, completion: { tsUrls, error in
//                        
//                        //print("====kkvideocache fetch master480 success", tsUrls)
//                        if(tsUrls.count > 0){
//                            self.fetchUrl(urlString: tsUrls[0], completion: { (data) -> Void in
//                                if(data == nil){
//                                    print("==== -- 555 kkvideocache fetch master480[0] Failed", tsUrls[1])
//                                    completion(false)
//                                } else {
//                                    print("==== -- 555 kkvideocache fetch master480[0] success", tsUrls[1])
//                                    completion(true)
//                                }
//                            })
//                        } else {
//                            completion(false)
//                        }
//                    })
//                    
//                } else {
//                    if (tsUrls.count > 0 ){
//                        //print("====kkvideocache fetch master default success", tsUrls)
//                        self.fetchUrl(urlString: tsUrls[0], completion: { (data) -> Void in
//                            
//                            if(data == nil){
//                                print("==== -- 555 kkvideocache fetch TS[0] Failed", tsUrls[0])
//                                completion(false)
//                            } else {
//                                print("==== -- 555 kkvideocache fetch TS[0] success", tsUrls[0])
//                                if(tsUrls.count > 1){
//                                    self.fetchUrl(urlString: tsUrls[1], completion: { (data) -> Void in
//                                        if(data == nil){
//                                            print("==== -- 555 kkvideocache fetch TS[1] Failed", tsUrls[1])
//                                            completion(false)
//                                        } else {
//                                            print("==== -- 555 kkvideocache fetch TS[1] success", tsUrls[1])
//                                            completion(true)
//                                        }
//                                    })
//                                } else {
//                                    completion(true)
//                                }
//                            }
//                        })
//
//                    } else {
//                        completion(true)
//                    }
//                }
//            })
//
//        }
        
    }
    
    private func fetchUrl(urlString: String, completion:  @escaping (Data?) -> ()) {
        if(urlString != ""){
            let url = URL(string: urlString)
            
            let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
                
                if let httpResponse = response as? HTTPURLResponse {
                    //print("statusCode: \(httpResponse.statusCode)")
                    if(httpResponse.statusCode == 200){
                        //print("---- response",  response, "error", error, "url", url)
                        guard let data = data else { return }
                        completion(data)
                    } else {
                        completion(nil)
                    }
                }

            }
            task.resume()
        }
    }
    
    private func fetchMaster(urlString: String, completion: @escaping([String], URLError?) -> Void){
        if(urlString != ""){
            self.fetchUrl(urlString: urlString, completion: { data in
                
                guard let data = data else {
                    return
                    //completion([""], URLError(URLError.badServerResponse))
                }
                
                let tsUrls = self.extractTSUrls(data: data)
                
                if(tsUrls.count == 0){
                    let dataString = String(data: data, encoding: .utf8)
                    print("****** extractTSUrls", "FAILED")
                    
                    completion(tsUrls, URLError(URLError.badURL))
                    //completion(t)
                } else {
                    completion(tsUrls, nil)
                }
                
                
            })
        }
    }
    
    private func extractTSUrls(data: Data) -> [String]{
        let dataString = String(data: data, encoding: .utf8)
        let dataArray = dataString?.components(separatedBy: "\n")
        var indexUrl = 0
         // set how many TS you want to cache
        var urls = [String]()
        //print("123DataString \(dataString)")
        dataArray?.forEach({ url in
            if(url.hasPrefix("http://") && indexUrl < MAX_TS){
                urls.append(url)
                indexUrl += 1
            }
        })
        
        return urls
    }

    public func selectPlaylist(source: String, toPlaylist: KKVideoResolution) -> String {
        // this function will replace last source URL segment
        // ex: from : https://asset.kipaskipas.com/media/stream/1644289784509/1644289784509.m3u8
        //     to   : https://asset.kipaskipas.com/media/stream/1644289784509/720p.m3u8
        
        let urlMasterSplits = source.split(separator: "/")
        if(urlMasterSplits.count > 0){
            let lastMasterName = urlMasterSplits[urlMasterSplits.count-1]
            let urlReplacement = source.replacingOccurrences(of: lastMasterName, with: toPlaylist.rawValue + ".m3u8")
            return urlReplacement
        }
        return source
    }
        
    public func getVideoId(urlPath: String) -> String {
        let pathOfUrl = urlPath.components(separatedBy: "/")
        let videoId = pathOfUrl[pathOfUrl.count-2]
        return videoId
    }
    
    public func isFileExist(url: String) -> Bool {
            do {
                let documentsURL = try
                    FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let checkedPath = documentsURL.appendingPathComponent(url)
                if FileManager.default.fileExists(atPath: checkedPath.path) {
                    return true
                }
            } catch {
                print(error)
            }
            return false
        }



}

