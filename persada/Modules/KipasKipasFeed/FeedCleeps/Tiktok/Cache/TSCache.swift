//
//  TSCache.swift
//  KipasKipas
//
//  Created by koanba on 07/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

struct TSCache {
    var mediaName: String
    var segment: String
    var url: String
    
    func key() -> String{
        return mediaName + "-" + segment
    }
}
