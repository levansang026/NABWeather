//
//  ForecastError.swift
//  
//
//  Created by Sang Le on 7/3/22.
//

import Foundation

public enum ForecastError: Error {
    
    case somethingWentWrong
    case invalidValue
    case noInternetConnection
    case cityNotFound
    case custom(String)
}
