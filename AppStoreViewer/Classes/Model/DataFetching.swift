//
//  DataFetching.swift
//  AppStoreViewer
//
//  Created by Gil Nakache on 11/12/2018.
//  Copyright © 2018 Viseo. All rights reserved.
//

import Foundation

// Protocol used to mock network calls for testing
public protocol DataFetching {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void)
}
