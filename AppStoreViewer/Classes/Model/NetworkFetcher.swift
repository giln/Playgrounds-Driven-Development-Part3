//
//  NetworkFetcher.swift
//  AppStoreViewer
//
//  Created by Gil Nakache on 11/12/2018.
//  Copyright © 2018 Viseo. All rights reserved.
//

import Foundation

// Network fetching
class NetworkFetcher: DataFetching {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let session = URLSession.shared

        session.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
            }.resume()
    }
}
