//
//  KKBufferPlayerApp.swift
//  KipasKipasFeed
//
//  Created by koanba on 05/09/23.
//

import Foundation

class KKBufferPlayerApp {
    
    public static let instance = KKBufferPlayerApp()
    
    let LOG_ID = "=== KKBufferPlayerApp"
    
    let MARGIN_BUFFER_MIN = 3.0
    
    func hasBuffer(total totalDuration: Double,
                     playable playableDuration: Double,
                     progress progressDuration: Double) -> Bool {

        let isBufferFull = playableDuration == totalDuration ? true : false
        
        let marginBufferCurrent = playableDuration - progressDuration
        
        let marginTotalDuration = playableDuration - playableDuration
        
        var hasBuffer = false
        
        if isBufferFull {
            hasBuffer = true
        } else {
            if marginBufferCurrent >= MARGIN_BUFFER_MIN {
                hasBuffer = true
            }
        }
        
        print(self.LOG_ID, "fullDuration:", totalDuration.rounded(),
              "progress:", progressDuration.rounded(),
              "playable:", playableDuration.rounded(),
              "hasBuffer:", hasBuffer)
        
        return hasBuffer

    }
    
}
