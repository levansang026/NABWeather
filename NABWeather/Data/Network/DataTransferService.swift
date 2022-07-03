//
//  DataTransferService.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import NABWeatherDomain
import Moya

enum DataTransferError: Error {
    
    case parsing(Error)
    case networkFailure(MoyaError)
}

protocol DataTransferService {
    
    associatedtype Target: TargetType
    
    typealias CompletionHandler<T> = (Result<T, ForecastError>) -> Void
    
    @discardableResult
    func requestThenDecode<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<E.Response>
    ) -> Cancellable
    where E.Target == Target
    
    @discardableResult
    func request<E: Requestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Moya.Response>
    ) -> Cancellable
    where E.Target == Target
}

final class DefaultDataTransferService<Target: TargetType> {
    
    private let networkProvider: NetworkProvider<Target>
    
    public init(config: NetworkConfigurable) {
        self.networkProvider = NetworkProvider<Target>(config: config)
    }
}

extension DefaultDataTransferService: DataTransferService {
    
    func requestThenDecode<E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<E.Response>
    ) -> Cancellable where E : ResponseRequestable, Target == E.Target {
    
        return networkProvider.request(endpoint.target) { result in
            switch result {
            case .success(let response):
                DispatchQueue.global(qos: .utility).async {
                    var result: Result<E.Response, ForecastError>
                    do {
                        let object = try response.map(E.Response.self, atKeyPath: endpoint.keyPath, using: endpoint.decoder)
                        result = .success(object)
                    } catch {
                        print("!!Networking Error: \(response.request?.url?.absoluteString ?? "unkown url") - \(error.localizedDescription)")
                        result = .failure(.somethingWentWrong)
                    }
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error.forecastError))
                }
            }
        }
    }
    
    func request<E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Response>
    ) -> Cancellable where E : Requestable, Target == E.Target {
        return networkProvider.request(endpoint.target) { result in
            switch result {
            case .success(let moyaResponse):
                DispatchQueue.main.async {
                    completion(.success(moyaResponse))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error.forecastError))
                }
            }
        }
    }
}

extension MoyaError {
    
    var forecastError: ForecastError {
        if case let .underlying(error, _) = self,
           let afError = error.asAFError,
           case let .sessionTaskFailed(sessionError) = afError {
            return (sessionError as? URLError)?.code == .notConnectedToInternet ? .noInternetConnection : .somethingWentWrong
        }
        return .somethingWentWrong
    }
}
