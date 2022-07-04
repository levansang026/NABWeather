//
//  ForecastViewModel.swift
//  NABWeather
//
//  Created by Sang Le on 7/4/22.
//

import Foundation
import NABWeatherDomain
import RxSwift
import RxRelay

protocol ForecastViewModel {
    
    // Input
    func processQuery(with keyword: String)
    
    // Output
    var forecastsHotSeq: Observable<[ForecastItem]> { get }
}

class DefaultForecastViewModel {
    
    private let getCityForecastUsecase: GetCityForecastUsecase
    private let forecastRepository: ForecastRepository
    private let forecastsRelay = BehaviorRelay<[ForecastItem]>(value: [])
    private let requestStr = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    init(
        getCityForecastUsecase: GetCityForecastUsecase,
        forecastRepository: ForecastRepository
    ) {
        self.getCityForecastUsecase = getCityForecastUsecase
        self.forecastRepository = forecastRepository
        
        let cityForecastSeq = requestStr
            .filter { $0.isEmpty || $0.count >= 3 }
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .utility))
            .flatMapLatest { requestStr -> Observable<CityForecast?> in
                if requestStr.isEmpty {
                    return .just(nil)
                }
                let query = CityForecastQuery(name: requestStr.lowercased())
                return getCityForecastUsecase.execute(with: query)
                    .map { $0 as CityForecast? }
                    .catchAndReturn(nil)
                    .asObservable()
            }
        
        let unitSetting = Observable.just(ForecastItem.Unit.celsius)
        
        Observable.combineLatest(cityForecastSeq, unitSetting)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
            .map { cityForecast, unit in
                cityForecast?.forecasts.map {
                    
                    var average = $0.temperature.day
                    switch unit {
                    case .celsius: break
                    case .fahrenheit: average = average * 9 / 5 + 32
                    }
                    
                    return ForecastItem(
                        id: "\($0.date.timeIntervalSince1970)",
                        date: $0.date,
                        averageTemp: average,
                        pressure: $0.pressure,
                        humidity: $0.humidity,
                        description: $0.weathers.first?.description ?? "N/A",
                        iconUrlStr: $0.weathers.first?.iconUrlStr ?? "",
                        unit: unit
                    )
                } ?? []
            }
            .catchAndReturn([])
            .bind(to: forecastsRelay)
            .disposed(by: disposeBag)
    }
}

extension DefaultForecastViewModel: ForecastViewModel {
    
    func processQuery(with keyword: String) {
        requestStr.accept(keyword)
    }
    
    var forecastsHotSeq: Observable<[ForecastItem]> {
        forecastsRelay.asObservable()
    }
}
