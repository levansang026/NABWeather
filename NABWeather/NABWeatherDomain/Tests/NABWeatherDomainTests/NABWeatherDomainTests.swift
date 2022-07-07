import XCTest
import RxSwift
import RxBlocking
import RxTest

@testable import NABWeatherDomain

class TestForeCastRepository: ForecastRepository {
    
    var dict = [String: CityForecast]()
    var latestStatus: String = ""
    static func mockedRemoteCities(numOfDays: Int) -> [CityForecast]  {
        
        let foreCasts = (1...numOfDays).map {
            DailyForecast(
                date: Date().addingTimeInterval(3600),
                sunrise: Date().addingTimeInterval(3600),
                sunset: Date().addingTimeInterval(18000),
                temperature: .init(day: 30.0, min: 30.0, max: 30.0, night: 30.0, eve: 30.0, morn: 30.0),
                weathers: [.init(id: "day\($0)", name: "day \($0)", description: "rain", iconUrlStr: "13d")],
                pressure: 1000,
                humidity: 90
            )
        }
        
        return [
            CityForecast(id: "1", name: "city1", forecasts: foreCasts),
            CityForecast(id: "2", name: "city2", forecasts: foreCasts),
            CityForecast(id: "3", name: "city3", forecasts: foreCasts),
            CityForecast(id: "4", name: "city4", forecasts: foreCasts)
        ]
    }
    
    func savedForecast(for query: CityForecastQuery) -> Single<CityForecast?> {
        let savedForecast = dict[query.name]
        if savedForecast != nil {
            latestStatus = "Cache hit: \(query.name)"
        }
        return .just(savedForecast)
    }
    
    func saveForecastResult(of query: CityForecastQuery, with forecast: CityForecast) -> Completable {
        dict[query.name] = forecast
        return .empty()
    }
    
    func fetchForecast(with query: CityForecastQuery) -> Single<CityForecast> {
        latestStatus = "Cache miss: \(query.name)"
        let forecast = Self.mockedRemoteCities(numOfDays: query.numberOfDay).first(where: {
            $0.name == query.name
        })
        
        guard let forecast = forecast else {
            return .error(ForecastError.cityNotFound)
        }
        
        return .just(forecast)
    }
}

final class NABWeatherDomainTests: XCTestCase {
    
    var forecastRespository: TestForeCastRepository!
    
    override func setUp() {
        forecastRespository = TestForeCastRepository()
    }
    
    override func tearDown() {
        forecastRespository.dict.removeAll()
        forecastRespository.latestStatus = ""
    }
    
    func testUsecaseReturnFirstMockedCity() throws {
        let usecase = DefaultGetCityForecastUsecase(forecastRepository: forecastRespository)
        let forecast = try usecase.execute(with: .init(name: "city1", numberOfDay: 1)).toBlocking().first()
        XCTAssertEqual(forecast?.id, TestForeCastRepository.mockedRemoteCities(numOfDays: 1).first?.id)
    }
    
    func testUsecaseReturnThirdMockedCity() throws {
        let usecase = DefaultGetCityForecastUsecase(forecastRepository: forecastRespository)
        let forecast = try usecase.execute(with: .init(name: "city3", numberOfDay: 4)).toBlocking().first()
        let mockedRemoteCities = TestForeCastRepository.mockedRemoteCities(numOfDays: 4)
        
        guard let mockedForecastCityIndex = mockedRemoteCities.firstIndex(where: { $0.name == "city3" }), mockedForecastCityIndex == 2 else {
            XCTFail("Pls check mocked data")
            return
        }
        
        XCTAssertEqual(
            forecast?.id,
            mockedRemoteCities[mockedForecastCityIndex].id
        )
    }
    
    func testUsecaseReturnCachedResultIfCacheHit() throws {
        let usecase = DefaultGetCityForecastUsecase(forecastRepository: forecastRespository)
        _ = usecase.execute(with: .init(name: "city1", numberOfDay: 1)).subscribe()
        let forecast = try usecase.execute(with: .init(name: "city1", numberOfDay: 1)).toBlocking().first()
        XCTAssertEqual(
            "Cache hit: city1",
            forecastRespository.latestStatus
        )
        XCTAssertEqual(
            forecast?.id,
            TestForeCastRepository.mockedRemoteCities(numOfDays: 1).first?.id
        )
    }
    
    func testUsecaseReturnCachedResultIfCacheMiss() throws {
        let usecase = DefaultGetCityForecastUsecase(forecastRepository: forecastRespository)
        let forecast = try usecase.execute(with: .init(name: "city3", numberOfDay: 1)).toBlocking().first()
        XCTAssertEqual(
            "Cache miss: city3",
            forecastRespository.latestStatus
        )
        XCTAssertEqual(
            forecast?.id,
            TestForeCastRepository.mockedRemoteCities(numOfDays: 1)[2].id
        )
    }
    
    func testUsecaseReturnCityNotFoundError() throws {
        let usecase = DefaultGetCityForecastUsecase(forecastRepository: forecastRespository)
        let result = usecase.execute(with: .init(name: "city6", numberOfDay: 1)).toBlocking().materialize()
        
        switch result {
        case .completed: XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(_, let error):
            XCTAssertEqual(ForecastError.cityNotFound.localizedDescription, error.localizedDescription)
        }
    }
    
    func testUsecaseReturnResultHasNumOfDaysEqualRequest() throws {
        let usecase = DefaultGetCityForecastUsecase(forecastRepository: forecastRespository)
        let result = try usecase.execute(with: .init(name: "city4", numberOfDay: 3)).toBlocking().first()
        XCTAssertEqual(3, result?.forecasts.count)
    }
}
