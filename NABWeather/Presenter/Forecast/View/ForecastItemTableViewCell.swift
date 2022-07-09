//
//  ForecastItemTableViewCell.swift
//  NABWeather
//
//  Created by Sang Le on 7/4/22.
//

import UIKit
import AlamofireImage

class ForecastItemTableViewCell: UITableViewCell {
    
    // MARK: - UI components
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "dateLabel"
        return label
    }()
    
    let averageTempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "averageTemp"
        return label
    }()
    
    let pressureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "pressureLabel"
        return label
    }()
    
    let humidityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "humidityLabel"
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "descriptionLabel"
        return label
    }()
    
    let weatherImageview: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.isHidden = true
        img.translatesAutoresizingMaskIntoConstraints = false
        img.accessibilityIdentifier = "weatherImageview"
        return img
    }()
    
    // MARK: - properties
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy"
        return dateFormatter
    }()
    
    // MARK: - Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpViews() {
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(averageTempLabel)
        contentView.addSubview(pressureLabel)
        contentView.addSubview(humidityLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(weatherImageview)
        
        NSLayoutConstraint.activate([
            // date label constraints
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 0.0),
            dateLabel.trailingAnchor.constraint(greaterThanOrEqualTo: weatherImageview.leadingAnchor, constant: -10.0),
            
            // average label constraints
            averageTempLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10.0),
            averageTempLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            averageTempLabel.trailingAnchor.constraint(greaterThanOrEqualTo: weatherImageview.leadingAnchor, constant: -10.0),
            
            // pressure label constraints
            pressureLabel.topAnchor.constraint(equalTo: averageTempLabel.bottomAnchor, constant: 10.0),
            pressureLabel.leadingAnchor.constraint(equalTo: averageTempLabel.leadingAnchor),
            pressureLabel.trailingAnchor.constraint(greaterThanOrEqualTo: weatherImageview.leadingAnchor, constant: -10.0),
            
            // humidity label constraints
            humidityLabel.topAnchor.constraint(equalTo: pressureLabel.bottomAnchor, constant: 10.0),
            humidityLabel.leadingAnchor.constraint(equalTo: pressureLabel.leadingAnchor),
            humidityLabel.trailingAnchor.constraint(greaterThanOrEqualTo: weatherImageview.leadingAnchor, constant: -10.0),
            
            // description label constraints
            descriptionLabel.topAnchor.constraint(equalTo: humidityLabel.bottomAnchor, constant: 10.0),
            descriptionLabel.leadingAnchor.constraint(equalTo: humidityLabel.leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0),
            descriptionLabel.trailingAnchor.constraint(greaterThanOrEqualTo: weatherImageview.leadingAnchor, constant: -10.0),
            
            // weather icon
            weatherImageview.widthAnchor.constraint(equalToConstant: 50.0),
            weatherImageview.heightAnchor.constraint(equalToConstant: 50.0),
            weatherImageview.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weatherImageview.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    func configure(with item: ForecastItem) {
        let dateStr = dateFormatter.string(from: item.date)
        dateLabel.text = String(format: "Date: %@", dateStr)
        
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        let tempValue = item.averageTemp.rounded(.toNearestOrEven)
        var measurement: Measurement<Unit>
        switch item.unit {
        case .celsius:
            measurement = Measurement(value: tempValue, unit: UnitTemperature.celsius)
            
        case .fahrenheit:
            measurement = Measurement(value: tempValue, unit: UnitTemperature.fahrenheit)
        }
        averageTempLabel.text = String(format: "Average Temprature: %@", measurementFormatter.string(from: measurement))
        
        pressureLabel.text = String(format: "Pressure: %d", item.pressure)
        humidityLabel.text = String(format: "Humidty: %d%%", item.humidity)
        descriptionLabel.text = String(format: "Description: %@", item.description)
        
        guard let url = URL(string: item.iconUrlStr) else {
            return
        }
        weatherImageview.af.setImage(withURL: url, imageTransition: .crossDissolve(0.2)) { [weak weatherImageview] imageResponse in
            weatherImageview?.isHidden = imageResponse.value == nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        weatherImageview.isHidden = true
        weatherImageview.image = nil
        weatherImageview.af.cancelImageRequest()
    }
    
    deinit {
        
    }
}
