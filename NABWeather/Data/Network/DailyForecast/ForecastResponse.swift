//
//  ForecastResponse.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import NABWeatherDomain

struct ForecastResponse: Codable {
    
    let cod: String
    let city: ForecastCityResponse?
    let list: [DailyForecastResponse]?
}

// MARK: - City Forecast
struct ForecastCityResponse: Codable {
    let id: Int
    let name: String
}

extension CityForecast {
    
    init(with response: ForecastCityResponse, forecasts: [NABWeatherDomain.DailyForecast]) {
        self.init(
            id: "\(response.id)",
            name: response.name,
            forecasts: forecasts
        )
    }
}


// MARK: - Daily Forecast
struct DailyForecastResponse: Codable {
    
    let dt: TimeInterval
    let sunrise: TimeInterval
    let sunset: TimeInterval
    let temp: TemperatureResponse
    let pressure: Int
    let humidity: Int
    let weather: [WeatherResponse]
}

extension NABWeatherDomain.DailyForecast {
    
    init(with response: DailyForecastResponse, iconUrlStrBuilder: ((String) -> String)) {
        
        self.init(
            date: Date(timeIntervalSince1970: response.dt),
            sunrise: Date(timeIntervalSince1970: response.sunrise),
            sunset: Date(timeIntervalSince1970: response.sunset),
            temperature: Temperature(with: response.temp),
            weathers: response.weather.map { Weather(with: $0, iconUrlStrBuilder: iconUrlStrBuilder) },
            pressure: response.pressure,
            humidity: response.humidity
        )
    }
}

// MARK: - Temperature
struct TemperatureResponse: Codable {
    
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

extension Temperature {
    
    init(with response: TemperatureResponse) {
        self.init(
            day: response.day,
            min: response.min,
            max: response.max,
            night: response.night,
            eve: response.eve,
            morn: response.morn
        )
    }
}

// MARK: - Wearther response
struct WeatherResponse: Codable {
    
    let id: Int
    let main: String
    let description: String
    let icon: String
}

extension Weather {
    
    init(with response: WeatherResponse, iconUrlStrBuilder: ((String) -> String)) {
        let iconUrlStr = iconUrlStrBuilder(response.icon)
        self.init(
            id: "\(response.icon)",
            name: response.main,
            description: response.description,
            iconUrlStr: iconUrlStr
        )
    }
}
