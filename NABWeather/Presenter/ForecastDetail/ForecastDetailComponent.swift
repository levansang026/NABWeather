//
//  ForecastDetailComponent.swift
//  NABWeather
//
//  Created by Sang Le on 7/9/22.
//

import UIKit
import NeedleFoundation

class ForecastDetailComponent: Component<EmptyDependency>, ForecastDetailBuilder {
    
    func buildVC(with bgColor: UIColor) -> ForecastDetailViewController {
        ForecastDetailViewController(color: bgColor)
    }
}

protocol ForecastDetailBuilder {
    
    func buildVC(with bgColor: UIColor) -> ForecastDetailViewController
}
