//
//  AVPlayerView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 09/11/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import AVFoundation

final class AVPlayerView: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

