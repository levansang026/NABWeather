//
//  ForecastRepositoryImpl.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import NABWeatherDomain
import RxSwift

class FastForecastRepositoryImpl {
    
    private static func buildIconLink(iconId: String) -> String {
        return "https://openweathermap.org/img/wn/\(iconId)@3x.png"
    }
    
    private let dataTransferService: AnyDataTransferService<DailyForecast>
    private let apiKey: String
    
    init(
        apiKey: String,
        dataTransferService: AnyDataTransferService<DailyForecast>
    ) {
        self.apiKey = apiKey
        self.dataTransferService = dataTransferService
    }
}

extension FastForecastRepositoryImpl: ForecastRepository {
    
    func savedForecast(for query: CityForecastQuery) -> Single<CityForecast?> {
        return .just(nil)
    }
    
    func saveForecastResult(of query: CityForecastQuery, with forecast: CityForecast) -> Completable {
        return .empty()
    }
    
    func fetchForecast(with query: CityForecastQuery) -> Single<CityForecast> {
        let dataTransferService = self.dataTransferService
        let apiKey = self.apiKey
        return Single.create { observer in
            let endpoint = ResponseEndpoint<ForecastResponse, DailyForecast>(target: .forecast(query, appId: apiKey))
            let cancelable = dataTransferService.requestThenDecode(with: endpoint) { result in
                switch result {
                case .success(let response):
                    if response.code == "200" {
                        if let city = response.city, let list = response.list {
                            let dailyForecasts = list.map {
                                NABWeatherDomain.DailyForecast(with: $0, iconUrlStrBuilder: Self.buildIconLink(iconId:))
                            }
                            let cityForecast = CityForecast(with: city, forecasts: dailyForecasts)
                            observer(.success(cityForecast))
                        } else {
                            observer(.failure(ForecastError.somethingWentWrong))
                        }
                    } else {
                        if response.code == "404" {
                            observer(.failure(ForecastError.cityNotFound))
                        } else {
                            observer(.failure(ForecastError.somethingWentWrong))
                        }
                    }
                    
                case .failure(let error):
                    observer(.failure(error))
                }
            }
            
            return Disposables.create {
                cancelable.cancel()
            }
        }.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
    }
}
