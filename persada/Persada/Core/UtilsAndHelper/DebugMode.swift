//
//  DebugMode.swift
//  KipasKipas
//
//  Created by koanba on 02/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
public class DebugMode {
    
//    func execute(_ completionBlock: () -> ())  {
//        if let value = ProcessInfo.processInfo.environment["RUNNING_MODE"] {
//            if(value == "DEBUG"){
//                completionBlock()
//            }
//        }
//        return
//    }

    func isTrue() -> Bool  {
        if let value = ProcessInfo.processInfo.environment["RUNNING_MODE"] {
            if(value == "DEBUG"){
                return true
            }
        }
        return false
    }

    func isModule(moduleName: String) -> Bool  {
        if let value = ProcessInfo.processInfo.environment["CURRENT_MODULE"] {
            if(value == moduleName){
                return true
            }
        }
        return false
    }

}
