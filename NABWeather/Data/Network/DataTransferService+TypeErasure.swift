//
//  DataTransferService+TypeErasure.swift
//  NABWeather
//
//  Created by Sang Le on 7/3/22.
//

import Foundation
import Moya

private class _AnyDataTransferServiceBase<Target: TargetType>: DataTransferService {
    
    init() {
        guard type(of: self) != _AnyDataTransferServiceBase.self else {
            fatalError("_AnyDataTransferServiceBase<Target> instances can not be created, create a subclass instance instead")
        }
    }
    
    func requestThenDecode<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<E.Response>
    ) -> Cancellable
    where E.Target == Target {
        fatalError("Must Override")
    }
    
    func request<E: Requestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Moya.Response>
    ) -> Cancellable
    where E.Target == Target {
        fatalError("Must Override")
    }
}

private class _AnyDataTransferServiceBox<Concrete: DataTransferService>: _AnyDataTransferServiceBase<Concrete.Target> {
    
    var concrete: Concrete
    
    init(_ concrete: Concrete) {
        self.concrete = concrete
    }
    
    override func requestThenDecode<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<E.Response>
    ) -> Cancellable
    where E.Target == Target {
        concrete.requestThenDecode(with: endpoint, completion: completion)
    }
    
    override func request<E: Requestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Moya.Response>
    ) -> Cancellable
    where E.Target == Target {
        concrete.request(with: endpoint, completion: completion)
    }
}

public class AnyDataTransferService<Target: TargetType>: DataTransferService {
    
    private let box: _AnyDataTransferServiceBase<Target>
    
    init<Concrete: DataTransferService>(_ concrete: Concrete) where Concrete.Target == Target {
        box = _AnyDataTransferServiceBox(concrete)
    }
    
    func requestThenDecode<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<E.Response>
    ) -> Cancellable
    where E.Target == Target {
        box.requestThenDecode(with: endpoint, completion: completion)
    }
    
    func request<E: Requestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Moya.Response>
    ) -> Cancellable
    where E.Target == Target {
        box.request(with: endpoint, completion: completion)
    }
}
