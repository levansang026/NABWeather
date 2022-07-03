//
//  ForecastRepository.swift
//  
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import RxSwift

public protocol ForecastRepository {
    
    func savedForecast(for query: CityForecastQuery) -> Single<CityForecast?>
    func saveForecastResult(of query: CityForecastQuery, with forecast: CityForecast) -> Completable
    
    func fetchForecast(with query: CityForecastQuery) -> Single<CityForecast>
}
