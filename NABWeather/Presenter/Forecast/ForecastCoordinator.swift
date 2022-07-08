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
    case detail
}

final class ForecastCoordinator: BaseCoordinator<ForecastRoute> {
    
    let window: UIWindow
    private let cache: Cache<String, CityForecast>
    
    init(window: UIWindow, cache: Cache<String, CityForecast>) {
        self.window = window
        self.cache = cache
        let navVC = UINavigationController()
        window.rootViewController = navVC
        super.init(rootViewcontroller: navVC, parent: nil, initialRoute: nil)
    }
    
    override func start() {
        navigate(with: ForecastRoute.main)
    }
    
    override func navigate(with route: Route) {
        guard let route = route as? ForecastRoute,
        let navVC = navigationController() else {
            return
        }
        
        switch route {
        case .main:
            let viewController = ForecastViewController()
            navVC.viewControllers = [viewController]
            
            let networkConfig = WeatherNetworkConfig()
            let service = DefaultDataTransferService<DailyForecast>(config: networkConfig)
            let forecastRepo = FastForecastRepositoryImpl(
                apiKey: "4a98c3bdd88cacf1fff121f0cce98184",
                dataTransferService: AnyDataTransferService(service),
                cache: cache
            )
            let viewModel = DefaultForecastViewModel(
                getCityForecastUsecase: DefaultGetCityForecastUsecase(forecastRepository: forecastRepo)
            )
            viewController.viewModel = viewModel
            viewController.coordinator = self
            
            window.makeKeyAndVisible()
            
        case .detail:
            let detailViewController = ForecastDetailViewController(color: .random())
            navVC.pushViewController(detailViewController, animated: true)
        }
    }
}

private extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

private extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}
