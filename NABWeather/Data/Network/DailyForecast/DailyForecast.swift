//
//  DailyForecast.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import NABWeatherDomain
import Moya

enum DailyForecast {
    
    case forecast(CityForecastQuery, appId: String)
}

extension DailyForecast: TargetType {
    
    var path: String {
        ""
    }
    
    
    public var method: Moya.Method {
        .get
    }
    
    public var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case .forecast(let query, let appId):
            var params = query.asDict()
            params["appid"] = appId
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}

extension CityForecastQuery {
    
    func asDict() -> [String: Any] {
        return [
            "q": name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "",
            "cnt": "\(numberOfDay)",
            "unit": "metric"
        ]
    }
}
