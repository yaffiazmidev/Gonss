//
//  KKBenchmark.swift
//  FeedCleeps
//
//  Created by koanba on 07/09/23.
//

import  Foundation

class KKBenchmark {
    
    public static let instance = KKBenchmark()
    
    let LOG_ID = "===KKBenchmark"
    
    var dateStart = NSDate()
    
    func start(){
        dateStart = NSDate()
    }
    
    func show(){
        print(self.LOG_ID, "interval:  \(-self.dateStart.timeIntervalSinceNow)")
    }
    
}

