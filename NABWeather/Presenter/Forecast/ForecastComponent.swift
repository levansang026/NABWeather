//
//  ForecastComponent.swift
//  NABWeather
//
//  Created by Sang Le on 7/9/22.
//

import UIKit
import NeedleFoundation
import NABWeatherDomain

class ForecastComponent: BootstrapComponent {

    var cache: Cache<String, CityForecast> {
        shared {
            Cache<String, CityForecast>.loadCache() ?? Cache()
        }
    }
    
    var dataTransferService: AnyDataTransferService<DailyForecast> {
        let networkConfig = WeatherNetworkConfig()
        let service = DefaultDataTransferService<DailyForecast>(config: networkConfig)
        return AnyDataTransferService(service)
    }
    
    var forecastRepository: ForecastRepository {
        FastForecastRepositoryImpl(
            apiKey: "4a98c3bdd88cacf1fff121f0cce98184",
            dataTransferService: dataTransferService,
            cache: cache
        )
    }
    
    var getCityForecastUsecase: GetCityForecastUsecase {
        DefaultGetCityForecastUsecase(forecastRepository: forecastRepository)
    }
    
    var forecastViewModel: ForecastViewModel {
        DefaultForecastViewModel(getCityForecastUsecase: getCityForecastUsecase)
    }
    
    var forecastViewViewController: ForecastViewController {
        let vc = ForecastViewController()
        vc.viewModel = forecastViewModel
        return vc
    }
    
    var forecastDetailComponent: ForecastDetailComponent {
        return ForecastDetailComponent(parent: self)
    }
}
