//
//  Temperature.swift
//  
//
//  Created by Sang Le on 7/3/22.
//

import Foundation

public struct Temperature {
    
    // Note that the temperature only serve Celsius
    
    public let day: Double
    public let min: Double
    public let max: Double
    public let night: Double
    public let eve: Double
    public let morn: Double
    
    public init(
        day: Double,
        min: Double,
        max: Double,
        night: Double,
        eve: Double,
        morn: Double
    ) {
        self.day = day
        self.min = min
        self.max = max
        self.night = night
        self.eve = eve
        self.morn = morn
    }
}
