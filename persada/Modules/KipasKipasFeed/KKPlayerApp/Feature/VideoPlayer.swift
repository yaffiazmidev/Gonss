//
//  VideoPlayer.swift
//  PlayerApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/06/23.
//

import Foundation
import AVFoundation
import UIKit

protocol VideoPlayerDelegate: AnyObject {
    /**
     This function will be called when the video buffer state changes
     - parameter newVariableValue value: Boolean value of the video buffer state.
     */
    func videoIsBuffering(newVariableValue value: Bool)
    
    /**
     This function is called when the state failed to load the video changed
     - parameter newVariableValue value:  Boolean value of the state failed to load the video.
     */
    func videoIsFailed(newVariableValue value: Bool)
    
    /**
     This function is called when the video watch duration changes
     - parameter currentTime: CMTime value of current time video playing .
     */
    func videoDidPlaying(currentTime: CMTime)
    
    /**
     This function is called when the video has reached the total duration (end)
     - parameter player: VideoPlayer.
     */
    
    func videoDidEndPlaying(player: VideoPlayer)
    
    /**
     This function is called only when onPlayerPixelBuffer. This function is not available in all classes that implement the VideoPlayer protocol, only available in TencentVideoPlayer.
     - parameter pixelBuffer: CVPixelBuffer.
     - warning:  This function is not available in all classes that implement the VideoPlayer protocol, only available in TencentVideoPlayer.
     
     # Notes: #
     1.  This function is not available in all classes that implement the VideoPlayer protocol, only available in TencentVideoPlayer.
     
     */
    func videoPixelBuffer(pixelBuffer: CVPixelBuffer)
}

// MARK: - For Optional Function Delegate
extension VideoPlayerDelegate {
    /**
     This function is called only when onPlayerPixelBuffer. This function is not available in all classes that implement the VideoPlayer protocol, only available in TencentVideoPlayer.
     - parameter pixelBuffer: CVPixelBuffer.
     - warning:  This function is not available in all classes that implement the VideoPlayer protocol, only available in TencentVideoPlayer.
     
     # Notes: #
     1.  This function is not available in all classes that implement the VideoPlayer protocol, only available in TencentVideoPlayer.
     
     */
    func videoPixelBuffer(pixelBuffer: CVPixelBuffer) {}
}

protocol VideoPlayer {
    // MARK: Section of Variable
    
    /**
     Get Instance of VideoPlayer
     - returns: VideoPlayer
     
     # Example #
     ```
     // VideoPlayer.instance
     ```
     */
    static var instance: VideoPlayer { get }
    
    
    /**
     Completion for VideoPlayer when changes occur
     
     # Notes: #
     1. Use this to observe changes that occur in VideoPlayer
     2. Extend the VideoPlayerDelegate protocol on the class to set this delegate on the class
     
     # Example #
     ```
     // VideoPlayer.instance.delegate = self
     ```
     
     */
    var delegate: VideoPlayerDelegate? { get set }
    
    /**
     Get view from videoplayer
     - returns: UIView
     
     # Example #
     ```
     // VideoPlayer.instance.playerView
     ```
     */
    var playerView: UIView { get }
    
    /**
     Get & Set pause value from video player
     - returns: Bool
     
     # Example #
     ```
     // VideoPlayer.instance.isPaused
     // VideoPlayer.instance.isPaused = true
     ```
     */
    var isPaused: Bool { get set }
    
    /**
     Get URL String/ID of Current Video
     - returns: String
     
     # Example #
     ```
     // VideoPlayer.instance.currentVideoUrl
     ```
     */
    var currentVideoUrl: String { get }
    
    /**
     Get total duration of video
     - returns: Double
     
     # Example #
     ```
     // VideoPlayer.instance.duration
     ```
     */
    var duration: Double { get }
    
    
    /**
     Get buffer state from videoPlayer
     - returns: Bool
     
     # Example #
     ```
     // VideoPlayer.instance.isBuffering
     ```
     */
    var isBuffering: Bool  { get }
    
    /**
     Get failed state from videoPlayer
     - returns: Bool
     
     # Example #
     ```
     // VideoPlayer.instance.isFailed
     ```
     */
    var isFailed:Bool { get }
    
    /**
     Get currentTime videoPlaying
     - returns: CMTime
     
     # Example #
     ```
     // VideoPlayer.instance.timePlaying
     ```
     */
    var timePlaying: CMTime { get }
    
    // MARK: Section of Function
    
    /**
     To initialize the player. It is not recommended to call this function outside the class that extends this protocol.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - warning: It is not recommended to call this function outside the class that extends this protocol
     
     # Notes: #
     1. It is not recommended to call this function outside the class that extends this protocol
     */
    func initialize()
    
    /**
     This function is used to set video on player with AVPlayerItem.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - parameter _ item: AVPlayerItem. Create an instance of AVPlayerItem to set video in player with this method.
     
     # Notes: #
     1. This function is used to set video on player with AVPlayerItem.
     
     # Example #
     ```
     // VideoPlayer.instance.set(item)
     ```
     */
    func set(_ item: AVPlayerItem)
    
    /**
     This function is used to set video on player with AVPlayerItem and Duration in Seconds with datatype Double.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - parameter _ item: AVPlayerItem. Create an instance of AVPlayerItem to set video in player with this method.
     - parameter withDuration: Double. Duration in Seconds.
     
     # Notes: #
     1. This function is used to set video on player with AVPlayerItem and Duration in Seconds with datatype Double.
     
     # Example #
     ```
     // VideoPlayer.instance.set(item, withDuration: 0.0)
     ```
     */
    func set(_ item: AVPlayerItem, withDuration: Double)
    
    /**
     This function is used to set video on player with String URL/Video ID.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - parameter _ url: String. Convert URL to String if you wanna use this method. Or you can also fill it with VideoID.
     
     # Notes: #
     1. This function is used to set video on player with String URL/Video ID.
     
     # Example #
     ```
     // VideoPlayer.instance.set("url/VideoID")
     ```
     */
    func set(_ url: String)
    
    /**
     This function is used to set video on player with String URL/Video ID and Duration in Seconds with datatype Double.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - parameter _ url: String. Convert URL to String if you wanna use this method. Or you can also fill it with VideoID.
     - parameter withDuration: Double. Duration in Seconds.
     
     # Notes: #
     1. This function is used to set video on player with String URL/Video ID and Duration in Seconds with datatype Double.
     
     # Example #
     ```
     // VideoPlayer.instance.set("url/VideoID", withDuration: 0.0)
     ```
     */
    func set(_ url: String, withDuration: Double)
    
    /**
     Function to play video from player
     - parameter file: String? (Optional).
     - parameter function: String? (Optional).
     - parameter line: Int? (Optional).
     
     # Notes: #
     1. Function to play video from player
     2. File, function & line parameters are optional parameters & can be omitted. Parameters are used only for logging
     3. As much as possible do not fill in the File, function & line parameters unless you wrap this function with another function
     
     # Example #
     ```
     // VideoPlayer.instance.play()
            
     //If you want to wrap this function in another function, you can run it like this so that when logging you know the root of this function call.
     func customPlay(file: String = #file, function: String = #function, line: Int =  #line){
         VideoPlayer.instance.play(file: file, function: function, line: line)
     }
     
     //And you can call the function like this
     customPlay()
     ```
     */
    func play(file: String?, function: String?, line: Int?)
    //    func play()
    
    /**
     Function to play video from player
     - parameter fromBegining: Bool. To tell that the video will start from the beginning or not.
     - parameter file: String? (Optional).
     - parameter function: String? (Optional).
     - parameter line: Int? (Optional).
     
     # Notes: #
     1. Function to play video from player
     2. File, function & line parameters are optional parameters & can be omitted. Parameters are used only for logging
     3. As much as possible do not fill in the File, function & line parameters unless you wrap this function with another function
     
     # Example #
     ```
     // VideoPlayer.instance.play(fromBegining: true)
            
     //If you want to wrap this function in another function, you can run it like this so that when logging you know the root of this function call.
     func customPlay(fromBegining: Bool, file: String = #file, function: String = #function, line: Int =  #line){
         VideoPlayer.instance.play(fromBegining: fromBegining, file: file, function: function, line: line)
     }
     
     //And you can call the function like this
     customPlay(fromBegining: false)
     ```
     */
    func play(fromBegining: Bool, file: String?, function: String?, line: Int?)
    //    func play()
    
    /**
     Function to pause video from player
     - parameter file: String? (Optional).
     - parameter function: String? (Optional).
     - parameter line: Int? (Optional).
     
     # Notes: #
     1. Function to pause video from player
     2. File, function & line parameters are optional parameters & can be omitted. Parameters are used only for logging
     3. As much as possible do not fill in the File, function & line parameters unless you wrap this function with another function
     
     # Example #
     ```
     // VideoPlayer.instance.pause()
            
     //If you want to wrap this function in another function, you can run it like this so that when logging you know the root of this function call.
     func customPause(file: String = #file, function: String = #function, line: Int =  #line){
         VideoPlayer.instance.pause(file: file, function: function, line: line)
     }
     
     //And you can call the function like this
     customPause()
     ```
     */
    func pause(file: String?, function: String?, line: Int?)
    //    func pause()
}

// MARK: - For Optional Function
extension VideoPlayer {
    // MARK: Section of Variable
    //    var playerView : UIView? { get { return nil } }
    
    // MARK: Section of Function
    
    /**
     To initialize the player. It is not recommended to call this function outside the class that extends this protocol.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - warning: It is not recommended to call this function outside the class that extends this protocol
     
     # Notes: #
     1. It is not recommended to call this function outside the class that extends this protocol
     */
    func initialize() {}
    
    /**
     This function is used to set video on player with AVPlayerItem.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - parameter _ item: AVPlayerItem. Create an instance of AVPlayerItem to set video in player with this method.
     
     # Notes: #
     1. This function is used to set video on player with AVPlayerItem.
     
     # Example #
     ```
     // VideoPlayer.instance.set(item)
     ```
     */
    func set(_ item: AVPlayerItem) {}
    
    /**
     This function is used to set video on player with AVPlayerItem and Duration in Seconds with datatype Double.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - parameter _ item: AVPlayerItem. Create an instance of AVPlayerItem to set video in player with this method.
     - parameter withDuration: Double. Duration in Seconds.
     
     # Notes: #
     1. This function is used to set video on player with AVPlayerItem and Duration in Seconds with datatype Double.
     
     # Example #
     ```
     // VideoPlayer.instance.set(item, withDuration: 0.0)
     ```
     */
    func set(_ item: AVPlayerItem, withDuration: Double) {}
    
    /**
     This function is used to set video on player with String URL/Video ID.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - parameter _ url: String. Convert URL to String if you wanna use this method. Or you can also fill it with VideoID.
     
     # Notes: #
     1. This function is used to set video on player with String URL/Video ID.
     
     # Example #
     ```
     // VideoPlayer.instance.set("url/VideoID")
     ```
     */
    func set(_ url: String) {}
    
    /**
     This function is used to set video on player with String URL/Video ID and Duration in Seconds with datatype Double.
     This is an **optional** function/variable or not required to be implemented/owned by the class that inherits this protocol.
     - parameter _ url: String. Convert URL to String if you wanna use this method. Or you can also fill it with VideoID.
     - parameter withDuration: Double. Duration in Seconds.
     
     # Notes: #
     1. This function is used to set video on player with String URL/Video ID and Duration in Seconds with datatype Double.
     
     # Example #
     ```
     // VideoPlayer.instance.set("url/VideoID", withDuration: 0.0)
     ```
     */
    func set(_ url: String, withDuration: Double) {}
}

// MARK: - For assign default value to optional parameter
extension VideoPlayer {
    // Remove this function if parameters with default values are no longer needed
    /**
     Function to play video from player
     - parameter file: String? (Optional).
     - parameter function: String? (Optional).
     - parameter line: Int? (Optional).
     
     # Notes: #
     1. Function to play video from player
     2. File, function & line parameters are optional parameters & can be omitted. Parameters are used only for logging
     3. As much as possible do not fill in the File, function & line parameters unless you wrap this function with another function
     
     # Example #
     ```
     // VideoPlayer.instance.play()
            
     //If you want to wrap this function in another function, you can run it like this so that when logging you know the root of this function call.
     func customPlay(file: String = #file, function: String = #function, line: Int =  #line){
         VideoPlayer.instance.play(file: file, function: function, line: line)
     }
     
     //And you can call the function like this
     customPlay()
     ```
     */
    func play(_file: String = #file, _function: String = #function, _line: Int =  #line){
        play(file: _file, function: _function, line: _line)
    }
    
    // Remove this function if parameters with default values are no longer needed
    /**
     Function to play video from player
     - parameter fromBegining: Bool. To tell that the video will start from the beginning or not.
     - parameter file: String? (Optional).
     - parameter function: String? (Optional).
     - parameter line: Int? (Optional).
     
     # Notes: #
     1. Function to play video from player
     2. File, function & line parameters are optional parameters & can be omitted. Parameters are used only for logging
     3. As much as possible do not fill in the File, function & line parameters unless you wrap this function with another function
     
     # Example #
     ```
     // VideoPlayer.instance.play(fromBegining: true)
            
     //If you want to wrap this function in another function, you can run it like this so that when logging you know the root of this function call.
     func customPlay(fromBegining: Bool, file: String = #file, function: String = #function, line: Int =  #line){
         VideoPlayer.instance.play(fromBegining: fromBegining, file: file, function: function, line: line)
     }
     
     //And you can call the function like this
     customPlay(fromBegining: false)
     ```
     */
    func play(fromBegining: Bool, _file: String = #file, _function: String = #function, _line: Int =  #line){
        play(fromBegining: fromBegining, file: _file, function: _function, line: _line)
    }
    
    // Remove this function if parameters with default values are no longer needed
    /**
     Function to pause video from player
     - parameter file: String? (Optional).
     - parameter function: String? (Optional).
     - parameter line: Int? (Optional).
     
     # Notes: #
     1. Function to pause video from player
     2. File, function & line parameters are optional parameters & can be omitted. Parameters are used only for logging
     3. As much as possible do not fill in the File, function & line parameters unless you wrap this function with another function
     
     # Example #
     ```
     // VideoPlayer.instance.pause()
            
     //If you want to wrap this function in another function, you can run it like this so that when logging you know the root of this function call.
     func customPause(file: String = #file, function: String = #function, line: Int =  #line){
         VideoPlayer.instance.pause(file: file, function: function, line: line)
     }
     
     //And you can call the function like this
     customPause()
     ```
     */
    func pause(_file: String = #file, _function: String = #function, _line: Int =  #line){
        pause(file: _file, function: _function, line: _line)
    }
}
