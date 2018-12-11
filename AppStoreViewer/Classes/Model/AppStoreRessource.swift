//
//  AppStoreRessource.swift
//  AppStoreViewer
//
//  Created by Gil Nakache on 11/12/2018.
//  Copyright © 2018 Viseo. All rights reserved.
//

import Foundation

public enum RessourceError: Error {
    case networkError
    case decodingKeyNotFound(key: CodingKey)
    case decodingTypeMismatch
    case otherDecodingError
}

public class AppStoreRessource {
    // MARK: - Init

    init(datafetcher: DataFetching) {
        self.datafetcher = datafetcher
    }

    private let datafetcher: DataFetching

    // Internal struct used because of the way the json is wrapped
    private struct ServerResponse: Decodable {
        let feed: Feed
    }

    // Internal struct used because of the way the json is wrapped
    private struct Feed: Decodable {
        let entry: [App]
    }

    public func getTopApps(completion: @escaping ([App], RessourceError?) -> Void) {
        let urlString = "https://itunes.apple.com/fr/rss/toppaidapplications/limit=10/json"

        let url = URL(string: urlString)!

        datafetcher.fetchData(url: url) { data, _ in

            guard let data = data else {
                completion([], .networkError)
                return
            }

            do {
                _ = try JSONDecoder().decode(ServerResponse.self, from: data)
                completion([], nil)
            } catch DecodingError.keyNotFound(let key, _) {
                completion([], .decodingKeyNotFound(key: key))
            } catch DecodingError.typeMismatch(_, _) {
                completion([], .decodingTypeMismatch)
            } catch {
                print(error)
                completion([], .otherDecodingError)
            }
        }
    }
}
