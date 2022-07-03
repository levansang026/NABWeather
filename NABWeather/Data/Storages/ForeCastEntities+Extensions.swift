//
//  ForeCastEntities+Extensions.swift
//  NABWeather
//
//  Created by Sang Le on 7/4/22.
//

import Foundation
import NABWeatherDomain

extension CityForecast: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name, forecasts
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(forecasts, forKey: .forecasts)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let forecasts = try container.decode([NABWeatherDomain.DailyForecast].self, forKey: .forecasts)
        self.init(id: id, name: name, forecasts: forecasts)
    }
}

extension NABWeatherDomain.DailyForecast: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case date,
             sunrise,
             sunset,
             temperature,
             weathers,
             pressure,
             humidity
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(sunrise, forKey: .sunrise)
        try container.encode(sunset, forKey: .sunset)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(weathers, forKey: .weathers)
        try container.encode(pressure, forKey: .pressure)
        try container.encode(humidity, forKey: .humidity)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let date = try container.decode(Date.self, forKey: .date)
        let sunrise = try container.decode(Date.self, forKey: .sunrise)
        let sunset = try container.decode(Date.self, forKey: .sunset)
        let temperature = try container.decode(Temperature.self, forKey: .temperature)
        let weathers = try container.decode([Weather].self, forKey: .weathers)
        let pressure = try container.decode(Int.self, forKey: .pressure)
        let humidity = try container.decode(Int.self, forKey: .humidity)
        self.init(
            date: date,
            sunrise: sunrise,
            sunset: sunset,
            temperature: temperature,
            weathers: weathers,
            pressure: pressure,
            humidity: humidity
        )
    }
}

extension Temperature: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case day, min, max, night, eve, morn
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(day, forKey: .day)
        try container.encode(min, forKey: .min)
        try container.encode(max, forKey: .max)
        try container.encode(night, forKey: .night)
        try container.encode(eve, forKey: .eve)
        try container.encode(morn, forKey: .morn)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let day = try container.decode(Double.self, forKey: .day)
        let min = try container.decode(Double.self, forKey: .min)
        let max = try container.decode(Double.self, forKey: .max)
        let night = try container.decode(Double.self, forKey: .night)
        let eve = try container.decode(Double.self, forKey: .eve)
        let morn = try container.decode(Double.self, forKey: .morn)
        self.init(day: day, min: min, max: max, night: night, eve: eve, morn: morn)
    }
}

extension Weather: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, iconUrlStr
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(iconUrlStr, forKey: .iconUrlStr)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let description = try container.decode(String.self, forKey: .description)
        let iconUrlStr = try container.decode(String.self, forKey: .iconUrlStr)
        self.init(id: id, name: name, description: description, iconUrlStr: iconUrlStr)
    }
}
