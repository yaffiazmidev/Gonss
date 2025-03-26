//
//  FeedbackChecker.swift
//  KipasKipas
//
//  Created by PT.Koanba on 08/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol FeedbackChecker {
    typealias Result = Swift.Result<FeedbackCheckerItem, Error>
    
    func check(completion: @escaping (Result) -> Void)
}
