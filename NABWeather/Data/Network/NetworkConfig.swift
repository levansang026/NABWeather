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

struct WeatherNetworkConfig: NetworkConfigurable {
    
    let baseURL: URL
    let headers: [String: String]?
    
    public init() {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast/daily") else {
            fatalError()
        }
        self.baseURL = url
        headers = nil
    }
}
