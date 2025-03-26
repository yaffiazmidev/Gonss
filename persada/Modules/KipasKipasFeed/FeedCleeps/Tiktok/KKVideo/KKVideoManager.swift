//
//  KKVideoManager.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 14/08/23.
//

import Foundation

/**
 KKVideoManagerType is an enum for player type in KKVideoManager
 
 - returns: KKVideoManagerType
 - warning: KKVideoManagerType is called only once in the KKVideoManager class of the variable type
 
 # Example #
 ```
 // KKVideoManagerType.versa
 // KKVideoManagerType.tencent
 ```
 */
public enum KKVideoManagerType  {
    case versa
    case tencent
}

public class KKVideoManager {
    // MARK: Self Instance
    
    /**
     KKVideoManager is a manager for video player & preload of the entire application.
     - returns: KKVideoManager
     
     # Example #
     ```
     // KKVideoManager.instance
     ```
     */
    public static let instance: KKVideoManager = KKVideoManager()
    
    
    // MARK: Public Variable
    
    /**
     This variable is used to determine the player & preload that will be used. It is constant and may not be changed in other classes/places
     - warning: It is constant and may not be changed in other classes/places
     */
    public let type: KKVideoManagerType = .tencent
    
    /**
     Variable instance of the predefined video player. Current : KKVersaVideoPlayer & KKTencentVideoPlayer
     - returns: KKVideoPlayer
     
     # Example #
     ```
     // KKVideoManager.instance.player
     ```
     */
    public var player: KKVideoPlayer
    
    
    // MARK: Constructor
    private init() {
        switch(self.type){
        case .versa:
            self.player = KKVersaVideoPlayer.instance
        case .tencent:
            self.player = KKTencentVideoPlayer.instance
        }
    }
}
