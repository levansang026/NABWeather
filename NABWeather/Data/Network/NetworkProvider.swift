//
//  NetworkProvider.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import Moya

extension TargetType {
    var stubBehavior: StubBehavior {
        return sampleData == Data() ? .never : .delayed(seconds: 1)
    }
}

class NetworkProvider<Target: TargetType> {
    
    private let moyaProvider: MoyaProvider<Target>
    
    public init(config: NetworkConfigurable) {
        var plugins = [PluginType]()
        
#if DEBUG
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: [.verbose])
        let loggerPlugin = NetworkLoggerPlugin(configuration: loggerConfig)
        plugins.append(loggerPlugin)
#endif
        
        self.moyaProvider = MoyaProvider<Target>(
            endpointClosure: { target in
                NetworkProvider.endpointMapping(for: target, config: config)
            },
            stubClosure: { $0.stubBehavior },
            plugins: plugins
        )
    }
    
    private final class func endpointMapping(for target: Target, config: NetworkConfigurable) -> Moya.Endpoint {
        let endpoint = Moya.Endpoint(
            url: URL(target: target, config: config).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
        if let headers = config.headers {
            return endpoint.adding(newHTTPHeaderFields: headers)
        }
        return endpoint
    }
}

// MARK: - MoyaProviderType
extension NetworkProvider: MoyaProviderType {
    
    func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping Completion) -> Cancellable {
        moyaProvider.request(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}

// MARK: - URL + extension
extension URL {
    /// Initialize URL from Moya's `TargetType` and NetworkConfig
    init<T: TargetType>(target: T, config: NetworkConfigurable) {
        let targetPath = target.path
        if targetPath.isEmpty {
            self = config.baseURL
        } else {
            self = config.baseURL.appendingPathComponent(targetPath)
        }
    }
}
