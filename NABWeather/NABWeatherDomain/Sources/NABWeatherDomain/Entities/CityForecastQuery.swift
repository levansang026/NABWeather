//
//  File.swift
//  
//
//  Created by Sang Le on 7/3/22.
//

import Foundation

public struct CityForecastQuery {
    
    public let name: String
    public let numberOfDay: Int
    
    public init(name: String, numberOfDay: Int = 7) {
        self.name = name
        self.numberOfDay = numberOfDay
    }
}
