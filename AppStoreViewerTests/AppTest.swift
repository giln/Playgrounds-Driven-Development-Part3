//
//  AppTest.swift
//  AppStoreViewerTests
//
//  Created by Gil Nakache on 11/12/2018.
//  Copyright © 2018 Viseo. All rights reserved.
//

import XCTest

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
