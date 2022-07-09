//
//  NABWeatherForecastViewModelTests.swift
//  NABWeatherTests
//
//  Created by Sang Le on 7/9/22.
//

import XCTest
import NABWeatherDomain
import RxBlocking
import RxTest
import RxSwift
@testable import NABWeather

class TestForecastUsecase: GetCityForecastUsecase {
    
    private let mockedResult: Result<CityForecast, Error>
    
    init(mockedResult: Result<CityForecast, Error>) {
        self.mockedResult = mockedResult
    }
    
    func execute(with query: CityForecastQuery) -> Single<CityForecast> {
        switch mockedResult {
        case .success(let forecast): return .just(forecast)
        case .failure(let error): return .error(error)
        }
    }
}

class ComplicatedTestForecastUsecase: GetCityForecastUsecase {
    
    private static func genForecasts(for cityId: String) -> [NABWeatherDomain.DailyForecast] {
        return (1...7).map {
            DailyForecast(
                date: Date().addingTimeInterval(3600),
                sunrise: Date().addingTimeInterval(3600),
                sunset: Date().addingTimeInterval(18000),
                temperature: .init(day: 30.0, min: 30.0, max: 30.0, night: 30.0, eve: 30.0, morn: 30.0),
                weathers: [.init(id: "day\($0)-cityId", name: "day \($0)", description: "rain", iconUrlStr: "13d")],
                pressure: 1000,
                humidity: 90
            )
        }
    }
    
    private let mockedStuff: [CityForecast]
    init() {
        mockedStuff = [
            CityForecast(id: "city1", name: "City 1", forecasts: Self.genForecasts(for: "city1")),
            CityForecast(id: "city2", name: "City 2", forecasts: Self.genForecasts(for: "city2")),
            CityForecast(id: "city3", name: "City 3", forecasts: Self.genForecasts(for: "city3")),
            CityForecast(id: "city4", name: "City 4", forecasts: Self.genForecasts(for: "city4")),
            CityForecast(id: "city5", name: "City 5", forecasts: Self.genForecasts(for: "city5"))
        ]
    }
    
    func execute(with query: CityForecastQuery) -> Single<CityForecast> {
        let city = mockedStuff.first(where: {
            $0.name.lowercased().contains(query.name)
        })
        
        guard let city = city else {
            return .error(ForecastError.cityNotFound)
        }
        
        return .just(city)
    }
}

class NABWeatherForecastViewModelTests: XCTestCase {

    func testViewModelHasEmptyDailyForecastAsDefault() throws {
        let viewModel = DefaultForecastViewModel(
            getCityForecastUsecase: TestForecastUsecase(mockedResult: .failure(ForecastError.somethingWentWrong))
        )
        guard let defaultValue = try viewModel.forecastsHotSeq.toBlocking().first() else {
            XCTFail("Default value should be an empty list")
            return
        }
        
        switch defaultValue {
        case .success(let value):
            XCTAssertEqual(value, [])
            
        case .failure:
            XCTFail("Default value should be an empty list")
        }
    }

    func testViewModelNotFireForecastEventIFKeywordLengthLessThanThree() throws {
        let viewModel = DefaultForecastViewModel(
            getCityForecastUsecase: TestForecastUsecase(mockedResult: .failure(ForecastError.somethingWentWrong))
        )
        let resultCollecter = BehaviorSubject<Result<[ForecastItem], ForecastError>>(value: .success([]))
        viewModel.processQuery(with: "XC")
        _ = viewModel.forecastsHotSeq.skip(1)
            .subscribe(onNext: {
                resultCollecter.onNext($0)
            })
        sleep(1)
        DispatchQueue.main.async {
            resultCollecter.onCompleted()
        }
        let arr = try resultCollecter.toBlocking().toArray()
        XCTAssertEqual(arr.count, 1)
    }
    
    func testViewModelFireForecastError() throws {
        let error = NSError(domain: "Random Error", code: -999, userInfo: nil)
        let viewModel = DefaultForecastViewModel(
            getCityForecastUsecase: TestForecastUsecase(mockedResult: .failure(error))
        )
        let resultCollecter = BehaviorSubject<Result<[ForecastItem], ForecastError>>(value: .success([]))
        
        viewModel.processQuery(with: "nab")
        
        _ = viewModel.forecastsHotSeq
            .subscribe(onNext: {
                resultCollecter.onNext($0)
                if case .failure = $0 {
                    resultCollecter.onCompleted()
                }
            })
        
        let result = try resultCollecter.toBlocking().last()
        guard case .failure = result else {
            XCTFail("ViewModel not emit result as error, or error is not ForecastError")
            return
        }
        XCTAssert(true)
    }
    
    func testViewModelFireExpectedForeCastItems() throws {
        let dailyForecast = DailyForecast(
            date: Date().addingTimeInterval(3600),
            sunrise: Date().addingTimeInterval(3600),
            sunset: Date().addingTimeInterval(18000),
            temperature: .init(day: 30.0, min: 30.0, max: 30.0, night: 30.0, eve: 30.0, morn: 30.0),
            weathers: [.init(id: "day1", name: "day 1", description: "rain", iconUrlStr: "13d")],
            pressure: 1000,
            humidity: 90
        )
        
        let cityForecast = CityForecast(id: "city 1", name: "city 1", forecasts: [dailyForecast])
        let viewModel = DefaultForecastViewModel(
            getCityForecastUsecase: TestForecastUsecase(mockedResult: .success(cityForecast))
        )
        
        let resultCollecter = BehaviorSubject<Result<[ForecastItem], ForecastError>>(value: .success([]))
        
        viewModel.processQuery(with: "nab")
        
        _ = viewModel.forecastsHotSeq
            .subscribe(onNext: {
                resultCollecter.onNext($0)
                if case let .success(value) = $0,
                   !value.isEmpty {
                    resultCollecter.onCompleted()
                }
            })
        
        let result = try resultCollecter.toBlocking().last()
        guard let result = result else {
            XCTFail("Invalid value")
            return
        }

        switch result {
        case .success(let items):
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items.first!.id, "\(dailyForecast.date.timeIntervalSince1970)")
            
        case .failure:
            XCTFail("ViewModel fire expected result")
        }
    }
    
    func testViewModelReturnMultipleResults() throws {
        let viewModel = DefaultForecastViewModel(getCityForecastUsecase: ComplicatedTestForecastUsecase())
        let resultCollecter = BehaviorSubject<Result<[ForecastItem], ForecastError>>(value: .success([]))
        
        _ = viewModel.forecastsHotSeq
            .skip(1) // Ignore default value
            .subscribe(onNext: {
                resultCollecter.onNext($0)
            })
        
        DispatchQueue.main.async {
            viewModel.processQuery(with: "city 1")
            sleep(1)
            viewModel.processQuery(with: "city 3")
            sleep(1)
            viewModel.processQuery(with: "city 6")
            sleep(1)
            viewModel.processQuery(with: "")
            sleep(1)
            resultCollecter.onCompleted()
        }
        
        let arr = try resultCollecter.skip(1).toBlocking().toArray()
        
        guard arr.count == 4 else {
            XCTFail("Number of events not equal to expected")
            return
        }
        
        guard case let .success(value1) = arr[0], !value1.isEmpty,
              case let .success(value2) = arr[1], !value2.isEmpty,
              case let .failure(error) = arr[2], error.localizedDescription == ForecastError.cityNotFound.localizedDescription,
              case let .success(value3) = arr[3], value3.isEmpty else {
                  XCTFail("Events' result are not equal to expected")
                  return
              }
        
        XCTAssert(true)
    }
    
    func testViewModelChangeItemsTemperatureUnit() throws {
        let dailyForecast = DailyForecast(
            date: Date().addingTimeInterval(3600),
            sunrise: Date().addingTimeInterval(3600),
            sunset: Date().addingTimeInterval(18000),
            temperature: .init(day: 30.0, min: 30.0, max: 30.0, night: 30.0, eve: 30.0, morn: 30.0),
            weathers: [.init(id: "day1", name: "day 1", description: "rain", iconUrlStr: "13d")],
            pressure: 1000,
            humidity: 90
        )
        
        let cityForecast = CityForecast(id: "city 1", name: "city 1", forecasts: [dailyForecast])
        let viewModel = DefaultForecastViewModel(
            getCityForecastUsecase: TestForecastUsecase(mockedResult: .success(cityForecast))
        )
        
        let resultCollecter = BehaviorSubject<Result<[ForecastItem], ForecastError>>(value: .success([]))
        
        _ = viewModel.forecastsHotSeq
            .skip(1) // skip detault value
            .subscribe(onNext: {
                resultCollecter.onNext($0)
            })
        
        DispatchQueue.main.async {
            viewModel.processQuery(with: "nab")
            sleep(1)
            viewModel.toggleUnitSetting()
            sleep(1)
            viewModel.toggleUnitSetting()
            sleep(1)
            resultCollecter.onCompleted()
        }
        
        let arr = try resultCollecter.skip(1).toBlocking().toArray()
        
        guard arr.count == 3 else {
            XCTFail("Number of events not equal to expected")
            return
        }
        
        if case let .success(items) = arr[0] {
            XCTAssert(items.allSatisfy { $0.unit == .celsius }) // with default setting all items has unit is celsius
        } else {
            XCTFail("The first event has items' unit != celsius")
        }
        
        if case let .success(items) = arr[1] {
            XCTAssert(items.allSatisfy { $0.unit == .fahrenheit }) // Unit setting is toggled -> all items has unit is fahrenheit
        } else {
            XCTFail("The second event has items' unit != fahrenheit")
        }
        
        if case let .success(items) = arr[2] {
            XCTAssert(items.allSatisfy { $0.unit == .celsius }) // Unit setting is toggled -> all items has unit is celsius
        } else {
            XCTFail("The third event has items' unit != celsius")
        }
    }
    
    func testViewModelChangeUnitSetting() throws {
        let viewModel = DefaultForecastViewModel(
            getCityForecastUsecase: TestForecastUsecase(mockedResult: .failure(ForecastError.somethingWentWrong))
        )
        
        let unitCollector = PublishSubject<ForecastItem.Unit>()

        DispatchQueue.main.async {
            //Seem like toBlocking.toArray can't catch event immediately -> wrapped in async to collect all events
            _ = viewModel.forecastUnitHotSeq
                .subscribe(onNext: {
                    unitCollector.onNext($0)
                })
            
            viewModel.toggleUnitSetting()
            sleep(1)
            viewModel.toggleUnitSetting()
            sleep(1)
            unitCollector.onCompleted()
        }
        
        let unitArr = try unitCollector.toBlocking().toArray()
        guard unitArr.count == 3 else {
            XCTFail("Number of unit events not equal to expected")
            return
        }
        
        if unitArr[0] == .celsius {
            XCTAssert(true) // default setting is celsius
        } else {
            XCTFail("Default unit != celsius")
        }
        
        if unitArr[1] == .fahrenheit {
            XCTAssert(true) // unit should be fahrenheit
        } else {
            XCTFail("After the first toggling, unit != fahrenheit")
        }
        
        if unitArr[2] == .celsius {
            XCTAssert(true) // unit should be fahrenheit celsius
        } else {
            XCTFail("After the second toggling, unit != celsius")
        }
    }
}
