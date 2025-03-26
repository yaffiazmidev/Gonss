//
//  MovingAverage.swift
//  FeedCleeps
//
//  Created by koanba on 05/09/22.
//

import Foundation

class MovingAverage {
    var samples: Array<Double>
    var sampleCount = 0
    var period = 5
    
    init(period: Int = 5) {
        self.period = period
        samples = Array<Double>()
    }
    
    var average: Double {
        let sum: Double = samples.reduce(0, +)
        
        if period > samples.count {
            return sum / Double(samples.count)
        } else {
            return sum / Double(period)
        }
    }
    
    func addSample(value: Double) -> Double {
        let sampleCountInc = sampleCount + 1
        sampleCount = sampleCountInc
        let pos = Int(fmodf(Float(sampleCount), Float(period)))
        
        if pos >= samples.count {
            samples.append(value)
        } else {
            samples[pos] = value
        }
        
        return average
    }
}
