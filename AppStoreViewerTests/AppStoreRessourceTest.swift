//
//  AppStoreRessourceTest.swift
//  AppStoreViewerTests
//
//  Created by Gil Nakache on 11/12/2018.
//  Copyright © 2018 Viseo. All rights reserved.
//

import XCTest

// Tests for AppStoreRessource class
class AppStoreRessourceTest: XCTestCase {
    private var appStoreRessource: AppStoreRessource!
    private var mockFetcher: MockFetcher!

    override func setUp() {
        super.setUp()

        mockFetcher = MockFetcher()
        appStoreRessource = AppStoreRessource(datafetcher: mockFetcher)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAppStoreRessource() {
        XCTAssertNotNil(appStoreRessource)
    }

    func getTopAppsHelper(expectationDescription: String, jsonString: String? = nil, completion: @escaping (XCTestExpectation, [App], RessourceError?) -> Void) {
        let getExpectation = self.expectation(description: expectationDescription)

        mockFetcher.mockData = jsonString?.data(using: .utf8)
        appStoreRessource.getTopApps { apps, error in
            completion(getExpectation, apps, error)
        }

        self.wait(for: [getExpectation], timeout: 1.0)
    }

    func testGetTopAppsCompletes() {
        getTopAppsHelper(expectationDescription: "getTopApps did not complete") { expectation, _, _ in
            expectation.fulfill()
        }
    }

    func testGetTopAppsCompletesWithNetworkError() {
        // We don't pass any data to the mock on purpose
        getTopAppsHelper(expectationDescription: "getTopApps network error") { expectation, _, error in

            if case .some(.networkError) = error {
                expectation.fulfill()
            }
        }
    }

    func testGetTopAppsCompletesWithNoFeedError() {
        // our json string misses the "feed" on purpose
        getTopAppsHelper(expectationDescription: "getTopApps noFeedError",
                         jsonString: "{}") { getExpectation, _, error in
                            if case let .some(.decodingKeyNotFound(key)) = error, key.stringValue == "feed" {
                                getExpectation.fulfill()
                            }
        }
    }

    func testGetTopAppsCompletesWithNoEntryError() {
        // our json string misses the "entry" on purpose
        getTopAppsHelper(expectationDescription: "getTopApps noEntryError",
                         jsonString: "{ \"feed\" : {} }") { getExpectation, _, error in
                            if case let .some(.decodingKeyNotFound(key)) = error, key.stringValue == "entry" {
                                getExpectation.fulfill()
                            }
        }
    }

    func testGetTopAppsCompletesWithNoAppsError() {
        // our json string misses the apps array
        getTopAppsHelper(expectationDescription: "getTopApps noAppsError",
                         jsonString: "{ \"feed\" : { \"entry\" : {} } }") { getExpectation, _, error in
                            if case .some(.decodingTypeMismatch) = error {
                                getExpectation.fulfill()
                            }
        }
    }
}
