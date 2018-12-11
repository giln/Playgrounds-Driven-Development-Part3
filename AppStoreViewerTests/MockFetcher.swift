//
//  MockFetcher.swift
//  AppStoreViewerTests
//
//  Created by Gil Nakache on 11/12/2018.
//  Copyright © 2018 Viseo. All rights reserved.
//

import Foundation

// Mock fetching
class MockFetcher: DataFetching {
    public var mockData: Data?
    public var mockError: Error?

    func fetchData(url _: URL, completion: @escaping (Data?, Error?) -> Void) {
        completion(mockData, mockError)
    }
}
