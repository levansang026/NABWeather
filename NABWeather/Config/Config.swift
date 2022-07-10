//
//  Config.swift
//  NABWeather
//
//  Created by Sang Le on 7/10/22.
//

import Foundation

struct Config {
    
    static let appId = Config["APP_ID"]
}

extension Config {
    
    fileprivate static subscript(configKey: String) -> String {
        guard let config = Bundle.main.infoDictionary?[configKey] as? String else {
            fatalError("Cannot load config with key: \(configKey)")
        }
        return config
    }
}
