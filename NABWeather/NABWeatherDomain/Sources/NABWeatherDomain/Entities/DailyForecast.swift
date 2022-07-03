//
//  DailyForecast.swift
//  
//
//  Created by Sang Le on 7/3/22.
//

import Foundation

public struct DailyForecast {
    
    public let date: Date
    public let sunrise: Date
    public let sunset: Date
    
    public let temperature: Temperature
    public let weathers: [Weather]
    
    public let pressure: Int
    public let humidity: Int
    
    public init(
        date: Date,
        sunrise: Date,
        sunset: Date,
        temperature: Temperature,
        weathers: [Weather],
        pressure: Int,
        humidity: Int
    ) {
        self.date = date
        self.sunrise = sunrise
        self.sunset = sunset
        self.temperature = temperature
        self.weathers = weathers
        self.pressure = pressure
        self.humidity = humidity
    }
}
