import UIKit
import XCTest

// Protocol used to mock network calls for testing
public protocol DataFetching {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void)
}


public struct App {
    let name: String
    let summary: String
    let thumbImageUrl: String
}

extension App: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name = "im:name"
        case summary
        case image = "im:image"
    }

    private enum LabelKeys: String, CodingKey {
        case label
    }

    // Custom decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Read name
        let nameContainer = try container.nestedContainer(keyedBy: LabelKeys.self, forKey: .name)
        name = try nameContainer.decode(String.self, forKey: .label)

        // Read summary
        let summaryContainer = try container.nestedContainer(keyedBy: LabelKeys.self, forKey: .summary)
        summary = try summaryContainer.decode(String.self, forKey: .label)

        var imagesContainer = try container.nestedUnkeyedContainer(forKey: .image)

        var tempImageThumb = ""

        // We take the first image url
        while !imagesContainer.isAtEnd {
            let imageContainer = try imagesContainer.nestedContainer(keyedBy: LabelKeys.self)

            tempImageThumb = try imageContainer.decode(String.self, forKey: LabelKeys.label)
            break
        }

        thumbImageUrl = tempImageThumb
    }
}

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

// Mock fetching
class MockFetcher: DataFetching {
    public var mockData: Data?
    public var mockError: Error?

    func fetchData(url _: URL, completion: @escaping (Data?, Error?) -> Void) {
        completion(mockData, mockError)
    }
}

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

// Tests for App class
class AppTest: XCTestCase {
    let testJson = """
    {
                    "im:name": {
                        "label": "Toca Hair Salon 3"
                    },
                    "im:image": [{
                            "label": "https://is1-ssl.mzstatic.com/image/thumb/Purple128/v4/13/13/aa/1313aa3d-a782-5951-b902-735048917624/AppIcon-1x_U007emarketing-0-85-220-0-8.png/53x53bb-85.png",
                            "attributes": {
                                "height": "53"
                            }
                        },
                        {
                            "label": "https://is3-ssl.mzstatic.com/image/thumb/Purple128/v4/13/13/aa/1313aa3d-a782-5951-b902-735048917624/AppIcon-1x_U007emarketing-0-85-220-0-8.png/75x75bb-85.png",
                            "attributes": {
                                "height": "75"
                            }
                        },
                        {
                            "label": "https://is4-ssl.mzstatic.com/image/thumb/Purple128/v4/13/13/aa/1313aa3d-a782-5951-b902-735048917624/AppIcon-1x_U007emarketing-0-85-220-0-8.png/100x100bb-85.png",
                            "attributes": {
                                "height": "100"
                            }
                        }
                    ],
                    "summary": {
                        "label": "Welcome to Toca Hair Salon 3! Our most popular app"
    }
    }
    """

    func testApp() {
        XCTAssertNotNil(App(name: "name", summary: "summary", thumbImageUrl: "url"))
    }

    func testDecodableName() {
        let data = testJson.data(using: .utf8)
        let app = try? JSONDecoder().decode(App.self, from: data!)
        XCTAssertEqual(app?.name, "Toca Hair Salon 3")
    }

    func testDecodableSummary() {
        let data = testJson.data(using: .utf8)
        let app = try? JSONDecoder().decode(App.self, from: data!)
        XCTAssertEqual(app?.summary, "Welcome to Toca Hair Salon 3! Our most popular app")
    }

    func testDecodableThumbImageURL() {
        let data = testJson.data(using: .utf8)
        let app = try? JSONDecoder().decode(App.self, from: data!)
        XCTAssertEqual(app?.thumbImageUrl, "https://is1-ssl.mzstatic.com/image/thumb/Purple128/v4/13/13/aa/1313aa3d-a782-5951-b902-735048917624/AppIcon-1x_U007emarketing-0-85-220-0-8.png/53x53bb-85.png")
    }
}

// Run the tests
AppStoreRessourceTest.defaultTestSuite.run()
AppTest.defaultTestSuite.run()

