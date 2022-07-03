//
//  Endpoint.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import Moya

struct ResponseEndpoint<R: Decodable, Target>: ResponseRequestable {
    
    typealias Response = R
    let target: Target
    let keyPath: String?
    let decoder: JSONDecoder
    
    init(
        target: Target,
        keyPath: String? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.target = target
        self.keyPath = keyPath
        self.decoder = decoder
    }
}

struct Endpoint<Target>: Requestable {
    
    let target: Target
    
    init(target: Target) {
        self.target = target
    }
}
