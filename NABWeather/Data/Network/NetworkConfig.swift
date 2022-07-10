//
//  NetworkConfig.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation

protocol NetworkConfigurable {
    
    var baseURL: URL { get }
    var headers: [String: String]? { get }
}

protocol AppIdConfigurable {
    var paramkey: String { get }
    var paramValue: String { get }
}

struct WeatherNetworkConfig: NetworkConfigurable {
    
    let baseURL: URL
    let headers: [String: String]?
    private let appId: String
    
    public init(appId: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5") else {
            fatalError()
        }
        self.baseURL = url
        self.appId = appId
        headers = nil
    }
}

extension WeatherNetworkConfig: AppIdConfigurable {
    
    var paramkey: String {
        return "appid"
    }
    
    var paramValue: String {
        appId
    }
}
