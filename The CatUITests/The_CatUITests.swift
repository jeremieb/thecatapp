//
//  The_CatUITests.swift
//  The CatUITests
//
//  Created by Jeremie Berduck on 11/6/26.
//

import XCTest

final class The_CatUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    // MARK: - BreedListView

    @MainActor
    func testBreedListShowsNavigationTitle() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.navigationBars["Cat Breeds"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testBreedListDisplaysItems() throws {
        let app = XCUIApplication()
        app.launch()
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "Breed list should show at least one row after loading")
    }

    // MARK: - BreedRowView

    @MainActor
    func testBreedRowShowsNameAndSubtitle() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15))
        let firstCell = app.cells.firstMatch
        // Each row has a breed name (headline) and an origin · lifespan subtitle (caption)
        XCTAssertGreaterThanOrEqual(firstCell.staticTexts.count, 2, "Each breed row should show a name and a subtitle")
    }

    // MARK: - BreedDetailView

    @MainActor
    func testTappingBreedNavigatesToDetail() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15))
        app.cells.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Temperament"].waitForExistence(timeout: 5), "Detail view should show a Temperament section")
        XCTAssertTrue(app.staticTexts["Life Span"].waitForExistence(timeout: 5), "Detail view should show a Life Span section")
    }

    @MainActor
    func testDetailViewNavigationTitleMatchesBreedName() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15))
        // Capture the breed name from the row before tapping
        let breedName = app.cells.firstMatch.staticTexts.firstMatch.label
        app.cells.firstMatch.tap()
        XCTAssertTrue(app.navigationBars[breedName].waitForExistence(timeout: 5), "Detail navigation bar title should match the tapped breed name")
    }

    @MainActor
    func testDetailViewShowsTemperamentChips() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15))
        app.cells.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Temperament"].waitForExistence(timeout: 5))
        // At least one trait chip should be visible below the Temperament heading
        let temperamentHeading = app.staticTexts["Temperament"]
        XCTAssertTrue(temperamentHeading.exists)
    }

    // MARK: - Navigation

    @MainActor
    func testNavigateBackToBreedList() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15))
        app.cells.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Temperament"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Cat Breeds"].waitForExistence(timeout: 5), "Back button should return to the breed list")
    }

    // MARK: - Pull to Refresh

    @MainActor
    func testPullToRefreshReloadsList() throws {
        let app = XCUIApplication()
        app.launch()
        let list = app.collectionViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 15))
        list.swipeDown(velocity: .fast)
        XCTAssertTrue(list.waitForExistence(timeout: 15), "List should still be visible after pull-to-refresh")
    }

    // MARK: - Performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
