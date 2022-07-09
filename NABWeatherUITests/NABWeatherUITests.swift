//
//  NABWeatherUITests.swift
//  NABWeatherUITests
//
//  Created by Sang Le on 7/10/22.
//

import XCTest

class NABWeatherUITests: XCTestCase {

    func testSearchbarIsAutoFocus() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let weatherForecastNavigationBar = app.navigationBars["Weather Forecast"]
        let searchCitySearchField = weatherForecastNavigationBar.searchFields["Search City"]
        XCTAssertEqual(searchCitySearchField.value(forKey: "hasKeyboardFocus") as? Bool, true)
    }
    
    func testUnitToggleButtonAppearance() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let weatherForecastNavigationBar = app.navigationBars["Weather Forecast"]
        let rightBarButton = weatherForecastNavigationBar.buttons["°F"]
        XCTAssertEqual(rightBarButton.exists, true)

        rightBarButton.tap()
        let cRightBarButton = weatherForecastNavigationBar.buttons["°C"]
        XCTAssertEqual(cRightBarButton.exists, true)
    }
    
    func testDefaultListAppearance() throws {
        let app = XCUIApplication()
        app.launch()
        let tableView = app.tables.firstMatch
        XCTAssertEqual(tableView.exists, true)
        XCTAssertEqual(tableView.tableRows.count, 0)
    }
    
    func testListItemsCount() throws {
        let app = XCUIApplication()
        app.launch()
        
        let weatherForecastNavigationBar = app.navigationBars["Weather Forecast"]
        let searchCitySearchField = weatherForecastNavigationBar.searchFields["Search City"]
        searchCitySearchField.typeText("Paris")
        let tableView = app.tables.firstMatch
        XCTAssertEqual(tableView.exists, true)
        XCTAssertEqual(tableView.waitForElementsValueToMatch(predicate: NSPredicate(format: "cells.count == 7"), timeOut: .medium), true)
    }
    
    func testCellApperance() throws {
        let app = XCUIApplication()
        app.launch()
        
        let weatherForecastNavigationBar = app.navigationBars["Weather Forecast"]
        let searchCitySearchField = weatherForecastNavigationBar.searchFields["Search City"]
        searchCitySearchField.typeText("Saigon")
        let tableView = app.tables.firstMatch
        XCTAssertEqual(tableView.exists, true)
        XCTAssertEqual(tableView.waitForElementsValueToMatch(predicate: NSPredicate(format: "cells.count == 7"), timeOut: .medium), true)
        
        let cell = tableView.cells.firstMatch
        
        let dateLabel = cell.staticTexts.matching(identifier: "dateLabel").firstMatch
        XCTAssertEqual(dateLabel.exists, true)

        let averageTempLabel = cell.staticTexts.matching(identifier: "averageTemp").firstMatch
        XCTAssertEqual(averageTempLabel.exists, true)
        
        let pressureLabel = cell.staticTexts.matching(identifier: "pressureLabel").firstMatch
        XCTAssertEqual(pressureLabel.exists, true)
        
        let humidityLabel = cell.staticTexts.matching(identifier: "humidityLabel").firstMatch
        XCTAssertEqual(humidityLabel.exists, true)
        
        let descriptionLabel = cell.staticTexts.matching(identifier: "descriptionLabel").firstMatch
        XCTAssertEqual(descriptionLabel.exists, true)
        
        let weatherImageview = cell.images.matching(identifier: "weatherImageview").firstMatch
        XCTAssertEqual(weatherImageview.waitForElementsValueToMatch(predicate: NSPredicate(format: "exists == true"), timeOut: .medium), true)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

// MARK: - Conveniences
enum Timeout: TimeInterval {
    case extraSmall = 1
    case small      = 5
    case medium     = 10
    case large      = 20
}

extension XCUIElement {
    
    @discardableResult
    func waitForElementsValueToMatch(predicate: NSPredicate, timeOut: Timeout = .medium) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: timeOut.rawValue)
        
        return result == .completed
    }
}
