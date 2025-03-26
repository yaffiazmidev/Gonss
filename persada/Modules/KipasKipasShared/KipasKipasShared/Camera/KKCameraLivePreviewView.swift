//
//  KKCameraLivePreviewView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 04/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import AVFoundation

public class KKCameraLivePreviewView: UIView {
    
    public var previewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check KKCameraLivePreviewView.layerClass implementation.")
        }
        return layer
    }
    
    public var session: AVCaptureSession? {
        get {
            return previewLayer.session
        }
        set {
            previewLayer.session = newValue
        }
    }
    
    public override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
