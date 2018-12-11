//
//  App+Decodable.swift
//  AppStoreViewer
//
//  Created by Gil Nakache on 11/12/2018.
//  Copyright © 2018 Viseo. All rights reserved.
//

import Foundation

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
