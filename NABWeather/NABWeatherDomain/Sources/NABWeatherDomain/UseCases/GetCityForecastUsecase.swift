//
//  GetCityForecastUsecase.swift
//  
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import RxSwift

public protocol GetCityForecastUsecase {
    
    func execute(with query: CityForecastQuery) -> Single<CityForecast?>
}

public struct DefaultGetCityForecastUsecase {
    
    private let forecastRepository: ForeCastRepository
    
    public init(forecastRepository: ForeCastRepository) {
        self.forecastRepository = forecastRepository
    }
}

extension DefaultGetCityForecastUsecase: GetCityForecastUsecase {
    
    public func execute(with query: CityForecastQuery) -> Single<CityForecast?> {
        let forecastRepository = self.forecastRepository
        return forecastRepository.savedForecast(for: query)
            .flatMap { cachedForecast in
                if let cachedForecast = cachedForecast {
                    return .just(cachedForecast)
                }
                
                return forecastRepository.fetchForecast(with: query)
                    .do(onSuccess: {
                        guard let forecast = $0 else {
                            return
                        }
                        _ = forecastRepository.saveForecastResult(of: query, with: forecast)
                            .subscribe()
                    })
            }
    }
}
