//
//  ImageDataLoaderOSS.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 18/04/22.
//

import Foundation

public enum OSSSizeImage: String {
    case w40 = "40"
    case w80 = "80"
    case w100 = "100"
    case w140 = "140"
    case w240 = "240"
    case w360 = "360"
    case w480 = "480"
    case w576 = "576"
    case w720 = "720"
    case w1080 = "1080"
    case w1280 = "1280"
}

public final class ImageDataLoaderOSS {
    private init() {}

    private static let ossPerformance = "?x-oss-process=image/format,jpg/interlace,1/resize,w_"
    
    public static func enrich(_ url: URL, withSize size: OSSSizeImage = .w576) -> URL {
        guard url.absoluteString.contains("kipas") || url.absoluteString.contains("koanba") else { return url }
        return URL(string: "\(url.absoluteString)\(ossPerformance)\(size.rawValue)")!
    }
}
