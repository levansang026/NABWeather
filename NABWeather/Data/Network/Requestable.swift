//
//  Requestable.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation

public protocol Requestable {
    
    associatedtype Target
    var target: Target { get }
}

public protocol ResponseRequestable: Requestable {
    
    associatedtype Response: Decodable
    var keyPath: String? { get }
    var decoder: JSONDecoder { get }
}
