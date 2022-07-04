//
//  ForecastItem.swift
//  NABWeather
//
//  Created by Sang Le on 7/4/22.
//

import Foundation

struct ForecastItem: Hashable {
    
    enum Unit: Hashable {
        case celsius
        case fahrenheit
    }
    
    let id: String
    let date: Date
    let averageTemp: Double
    let pressure: Int
    let humidity: Int
    let description: String
    let iconUrlStr: String
    let unit: Unit
}
