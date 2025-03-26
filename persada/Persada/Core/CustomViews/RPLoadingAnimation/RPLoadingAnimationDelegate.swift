//
//  RPLoadingAnimationDelegate.swift
//  RPLoadingAnimation
//
//  Created by naoyashiga on 2015/10/11.
//  Copyright © 2015年 naoyashiga. All rights reserved.
//

import UIKit

protocol RPLoadingAnimationDelegate: AnyObject {
   func setup(_ layer: CALayer, size: CGSize, colors: [UIColor])
}
