//
//  ForecastCoordinator.swift
//  NABWeather
//
//  Created by Sang Le on 7/9/22.
//

import UIKit
import NABWeatherDomain

enum ForecastRoute: Route {
    
    case main
    case detail(UIColor)
}

final class ForecastCoordinator: BaseCoordinator<ForecastRoute> {
    
    let window: UIWindow
    private let component: ForecastComponent
    private let forecastDetailBuilder: ForecastDetailBuilder
    
    init(
        window: UIWindow,
        component: ForecastComponent,
        forecastDetailBuilder: ForecastDetailBuilder
    ) {
        self.window = window
        self.component = component
        self.forecastDetailBuilder = forecastDetailBuilder
        let navVC = UINavigationController()
        window.rootViewController = navVC
        super.init(rootViewcontroller: navVC, parent: nil, initialRoute: nil)
    }
    
    override func start() {
        navigate(with: .main)
    }
    
    override func navigate(with route: ForecastRoute) {
        guard let navVC = navigationController() else {
            return
        }
        
        switch route {
        case .main:
            let viewController = component.forecastViewViewController
            navVC.viewControllers = [viewController]
            viewController.coordinator = self
            window.makeKeyAndVisible()
            
        case .detail(let color):
            // For this case I don't think use needle to initialize detail VC is a good idea
            // Cus it is very simple, use needle is like make a dump
            // I just wana show the way that I use needle
            // In reality I will just use the init function of ForecastDetailViewController.
            let vc = forecastDetailBuilder.buildVC(with: color)
            navVC.pushViewController(vc, animated: true)
        }
    }
}
