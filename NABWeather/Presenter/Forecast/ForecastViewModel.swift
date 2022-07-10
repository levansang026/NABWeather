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
    func toggleUnitSetting()
    
    // Output
    var forecastsHotSeq: Observable<Result<[ForecastItem], ForecastError>> { get }
    var forecastUnitHotSeq: Observable<ForecastItem.Unit> { get }
    var shouldShowLoadingView: Observable<Bool> { get }
}

class DefaultForecastViewModel {
    
    private let forecastsRelay = BehaviorRelay<Result<[ForecastItem], ForecastError>>(value: .success([]))
    private let forecastUnitRelay = BehaviorRelay<ForecastItem.Unit>(value: .celsius)
    private let shouldShowLoadingViewRelay = BehaviorRelay<Bool>(value: false)
    private let requestStr = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    init(getCityForecastUsecase: GetCityForecastUsecase) {
        
        let cityForecastSeq = requestStr
            .filter { $0.isEmpty || $0.count >= 3 }
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .utility))
            .do(onNext: { [weak self] requestStr in
                guard !requestStr.isEmpty else {
                    return
                }
                self?.shouldShowLoadingViewRelay.accept(true)
            })
            .flatMapLatest { requestStr -> Observable<Result<CityForecast?, ForecastError>> in
                if requestStr.isEmpty {
                    return .just(.success(nil))
                }
                let query = CityForecastQuery(name: requestStr.lowercased())
                return getCityForecastUsecase.execute(with: query)
                    .map { .success($0 as CityForecast?) }
                    .catch({ error in
                        guard let error = error as? ForecastError else {
                            return .just(.failure(ForecastError.somethingWentWrong))
                        }
                        return .just(.failure(error))
                    })
                    .asObservable()
            }
        
        Observable.combineLatest(cityForecastSeq, forecastUnitRelay)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
            .map { cityForecastResult, unit in
                switch cityForecastResult {
                case .success(let cityForecast):
                    let items: [ForecastItem] = cityForecast?.forecasts.map {
                        
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
                    return .success(items)
                    
                case .failure(let error):
                    return .failure(error)
                }
            }
            .do(onNext: { [weak self] _ in
                self?.shouldShowLoadingViewRelay.accept(false)
            })
            .bind(to: forecastsRelay)
            .disposed(by: disposeBag)
    }
}

extension DefaultForecastViewModel: ForecastViewModel {
    
    func processQuery(with keyword: String) {
        requestStr.accept(keyword)
    }
    
    var forecastsHotSeq: Observable<Result<[ForecastItem], ForecastError>> {
        forecastsRelay.asObservable()
    }
    
    func toggleUnitSetting() {
        switch forecastUnitRelay.value {
        case .celsius: forecastUnitRelay.accept(.fahrenheit)
        case .fahrenheit: forecastUnitRelay.accept(.celsius)
        }
    }
    
    var forecastUnitHotSeq: Observable<ForecastItem.Unit> {
        forecastUnitRelay.asObservable()
    }
    
    var shouldShowLoadingView: Observable<Bool> {
        shouldShowLoadingViewRelay.asObservable()
    }
}
