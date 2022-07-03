//
//  CityForecast.swift
//  
//
//  Created by Sang Le on 7/2/22.
//

import Foundation

public struct CityForecast {
    
    public let id: String
    public let name: String
    public let forecasts: [DailyForecast]
    
    public init(
        id: String,
        name: String,
        forecasts: [DailyForecast]
    ) {
        self.id = id
        self.name = name
        self.forecasts = forecasts
    }
}
