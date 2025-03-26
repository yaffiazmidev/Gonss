//
//  KKBufferPlayer.swift
//  KipasKipasFeed
//
//  Created by koanba on 05/09/23.
//

import Foundation

class KKBufferPlayer {
    
    public static let instance = KKBufferPlayer()
    
    let LOG_ID = "=== KKBufferPlayer"
    
    let MARGIN_BUFFER_MIN = 3.0
    
    let MAX_END_MARGIN = 2.0
    
    func hasBuffer(total totalDuration: Double,
                     playable playableDuration: Double,
                     progress progressDuration: Double) -> Bool {

        let isBufferFull = playableDuration == totalDuration ? true : false
        
        let marginBufferCurrent = playableDuration - progressDuration
        
        //case: fullDuration: 43.0 progress: 41.0 playable: 39.0 hasBuffer: false
        let progressOverlapPlayable = progressDuration > playableDuration
        
        //case: fullDuration: 43.0 progress: 39.0 playable: 41.0 hasBuffer: false
        let reachMinimumEnd = (totalDuration - playableDuration) < MAX_END_MARGIN
                
        //case: fullDuration: 1.0 progress: 14.0 playable: 0.0 buffering: false
        let yetPlayable = playableDuration < 1.0
        
        
        var hasBuffer = false
        
        if yetPlayable {
            hasBuffer = false
        } else {
            if isBufferFull || progressOverlapPlayable || reachMinimumEnd {
                hasBuffer = true
            } else {
                if marginBufferCurrent >= MARGIN_BUFFER_MIN {
                    hasBuffer = true
                }
            }
        }

        
//        print(self.LOG_ID, "isBuffering..",", fullDuration:", totalDuration.rounded(),
//              "progress:", progressDuration.rounded(),
//              "playable:", playableDuration.rounded(),
//              //"hasBuffer:", hasBuffer,
//              "buffering:", !hasBuffer)
        
        return hasBuffer

    }
    
}
