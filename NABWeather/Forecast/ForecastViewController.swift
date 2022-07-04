//
//  ForecastViewController.swift
//  NABWeather
//
//  Created by Sang Le on 7/4/22.
//

import UIKit
import RxSwift
import RxCocoa

class ForecastViewController: UIViewController {
    
    typealias TableDataSource = UITableViewDiffableDataSource<Int, ForecastItem>

    private static let cellIdentifier = "ForecastItemTableViewCell"
    
    // Properties
    var viewModel: ForecastViewModel!
    private let disposeBag = DisposeBag()
    private lazy var datasource: TableDataSource = {
        let datasource = TableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, model) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath) as? ForecastItemTableViewCell
            cell?.configure(with: model)
            return cell
        })
        
        return datasource
    }()
    
    // UI Components
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        bindViewModel()
    }
    
    private func setUpViews() {
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            
            self.navigationItem.scrollEdgeAppearance = navigationBarAppearance
            self.navigationItem.standardAppearance = navigationBarAppearance
            self.navigationItem.compactAppearance = navigationBarAppearance
            
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        }
        title = "Weather Forecast"
        
        view.backgroundColor = .systemBackground
        tableView.register(ForecastItemTableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search City"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func bindViewModel() {
        
        viewModel.forecastsHotSeq
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] items in
                guard let self = self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Int, ForecastItem>()
                snapshot.appendSections([0])
                snapshot.appendItems(items, toSection: 0)
                self.datasource.apply(snapshot)
            })
            .disposed(by: disposeBag)
    }
}

extension ForecastViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        viewModel.processQuery(with: searchBar.text ?? "")
    }
}
