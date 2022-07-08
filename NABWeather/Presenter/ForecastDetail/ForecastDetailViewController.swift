//
//  ForecastDetailViewController.swift
//  NABWeather
//
//  Created by Sang Le on 7/9/22.
//

import UIKit

class ForecastDetailViewController: UIViewController {
    
    let color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color
    }
}
