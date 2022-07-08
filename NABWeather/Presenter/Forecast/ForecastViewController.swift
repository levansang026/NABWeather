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
    
    var coordinator: ForecastCoordinator?
    
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
    let searchController = UISearchController(searchResultsController: nil)
    let tableView = UITableView(frame: .zero, style: .plain)
    let statusLabel = UILabel()
    let rightBarButton = UIBarButtonItem()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        bindViewModel()
    }
    
    private func setUpViews() {
        
        title = "Weather Forecast"
        
        // Navigation bar
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            
            self.navigationItem.scrollEdgeAppearance = navigationBarAppearance
            self.navigationItem.standardAppearance = navigationBarAppearance
            self.navigationItem.compactAppearance = navigationBarAppearance
            
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        }
        
        rightBarButton.title = "°F"//°C"
        rightBarButton.rx.tap
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.toggleUnitSetting()
            })
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = rightBarButton
        
        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search City"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.becomeFirstResponder()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        rx.methodInvoked(#selector(viewDidAppear(_:)))
            .take(1)
            .subscribe(onNext: { [weak searchController] _ in
                searchController?.searchBar.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        // Views
        view.backgroundColor = .systemBackground
        tableView.register(ForecastItemTableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        view.addSubview(tableView)
        
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 3
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.isHidden = true
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            statusLabel.trailingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        
        viewModel.forecastsHotSeq
            .distinctUntilChanged({ oldResult, newResult in
                switch(oldResult, newResult) {
                case (.success(let oldItems), .success(let newItems)):
                    return oldItems == newItems
                    
                default: return false
                }
            })
            .asDriver(onErrorJustReturn: .success([]))
            .drive(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let items):
                    self.tableView.isHidden = false
                    self.statusLabel.isHidden = true
                    var snapshot = NSDiffableDataSourceSnapshot<Int, ForecastItem>()
                    snapshot.appendSections([0])
                    snapshot.appendItems(items, toSection: 0)
                    self.datasource.apply(snapshot, animatingDifferences: false)
                    
                case .failure(let error):
                    self.tableView.isHidden = true
                    self.statusLabel.isHidden = false
                    switch error {
                    case .somethingWentWrong, .custom, .invalidValue:
                        self.statusLabel.text = "Something Went Wrong.\n Please try again!"
                    
                    case .noInternetConnection:
                        self.statusLabel.text = "No Internet Connection!"
                        
                    case .cityNotFound:
                        self.statusLabel.text = "No City Found!"
                    }
                    
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.forecastUnitHotSeq
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .celsius)
            .map {
                switch $0 {
                case .celsius: return "°F"
                case .fahrenheit: return "°C"
                }
            }
            .drive(rightBarButton.rx.title)
            .disposed(by: disposeBag)
    }
}

extension ForecastViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        viewModel.processQuery(with: searchBar.text ?? "")
    }
}

extension ForecastViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.navigate(with: ForecastRoute.detail(.random()))
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
    }
}


private extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

private extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}
