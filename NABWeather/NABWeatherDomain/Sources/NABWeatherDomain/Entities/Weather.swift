//
//  Weather.swift
//  
//
//  Created by Sang Le on 7/3/22.
//

import Foundation

public struct Weather {
    
    public let id: String
    public let name: String
    public let description: String
    public let iconUrlStr: String
    
    public init(
        id: String,
        name: String,
        description: String,
        iconUrlStr: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconUrlStr = iconUrlStr
    }
}
