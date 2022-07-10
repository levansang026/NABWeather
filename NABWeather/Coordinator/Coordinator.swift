//
//  Coordinator.swift
//  NABWeather
//
//  Created by Sang Le on 7/9/22.
//

import UIKit

protocol Route { }

protocol Coordinator {
    
    var parent: Coordinator? { get }
    var children: [Coordinator] { get }
    var rootViewController: UIViewController? { get }
    
    func start()
    
    func removeFromParent()
    func add(child: Coordinator)
    func remove(child: Coordinator)
}

class BaseCoordinator<RouteType: Route>: Coordinator {
    
    let parent: Coordinator?
    private(set) var children = [Coordinator]()
    private(set) weak var rootViewController: UIViewController?
    let initialRoute: RouteType?
    
    public init(
        rootViewcontroller: UIViewController,
        parent: Coordinator?,
        initialRoute: RouteType?
    ) {
        self.rootViewController = rootViewcontroller
        self.parent = parent
        self.initialRoute = initialRoute
    }
    
    func start() {
        fatalError("Please override the \(#function) method.")
    }
    
    func navigate(with route: RouteType) {
        fatalError("Please override the \(#function) method.")
    }
    
    func add(child: Coordinator) {
        children.append(child)
    }
    
    func removeFromParent() {
        parent?.remove(child: self)
    }
    
    func remove(child: Coordinator) {
        children.removeAll(where: {
            $0.rootViewController == child.rootViewController
        })
    }
    
    func removeAllChild() {
        children.removeAll()
    }
    
    func navigationController() -> UINavigationController? {
        if let nav = rootViewController as? UINavigationController {
            return nav
        }
        if let tabBar = rootViewController as? UITabBarController,
           let selectedVC = tabBar.selectedViewController {
            return selectedVC.navigationController
        }
        return rootViewController?.navigationController
    }
}
