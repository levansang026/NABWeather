//
//  DailyForecast.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import NABWeatherDomain
import Moya

enum WeatherForecast {
    
    case dailyForecast(CityForecastQuery)
}

extension WeatherForecast: TargetType {
    
    var path: String {
        "/forecast/daily"
    }
    
    
    public var method: Moya.Method {
        .get
    }
    
    public var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case .dailyForecast(let query):
            return .requestParameters(parameters: query.asDict(), encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}

extension CityForecastQuery {
    
    func asDict() -> [String: Any] {
        return [
            "q": name,
            "cnt": "\(numberOfDay)",
            "units": "metric"
        ]
    }
}
