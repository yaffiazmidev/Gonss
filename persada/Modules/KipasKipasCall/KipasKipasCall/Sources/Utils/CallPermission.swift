//
//  CallPermission.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import AVFoundation

public class CallPermission {
    private static var _instance: CallPermission?
    private static let lock = NSLock()
    private let identifier: String = "CallPermission"
    
    public static var instance: CallPermission {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = CallPermission()
            }
        }
        return _instance!
    }
    
    private init() {}
    
    public func microphone(_ completion: ((_ granted: Bool) -> Void)? = nil) {
        if isMicrophonePermissionGranted() {
            completion?(true)
            return
        }
        
        requestMicrophonePermission { granted in
            completion?(granted)
        }
    }
    
    
    public func camera(_ completion: ((_ granted: Bool) -> Void)? = nil) {
        if isCameraPermissionGranted() {
            completion?(true)
            return
        }
        
        requestCameraPermission { granted in
            completion?(granted)
        }
    }
}

private extension CallPermission {
    func isMicrophonePermissionGranted() -> Bool {
        if #available(iOS 17.0, *) {
            switch (AVAudioApplication.shared.recordPermission) {
            case .granted: return true
            default: return false
            }
        } else {
            switch (AVAudioSession.sharedInstance().recordPermission) {
            case .granted: return true
            default: return false
            }
        }
    }
    
    func requestMicrophonePermission(_ completion: @escaping ((_ granted: Bool) -> Void)) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                completion(granted)
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                completion(granted)
            }
        }
    }
}

private extension CallPermission {
    func isCameraPermissionGranted() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            return true
        }
        return false
    }
    
    func requestCameraPermission(_ completion: @escaping ((_ granted: Bool) -> Void)) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            completion(granted)
        }
    }
}
