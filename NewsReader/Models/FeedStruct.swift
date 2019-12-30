//
//  FeedStruct.swift
//  NewsReader
//
//  Created by Aleksei Chupriienko on 12/6/19.
//  Copyright © 2019 Aleksei Chupriienko. All rights reserved.
//

import Foundation

struct FeedResponse: Codable {
    let results: [FeedItem]
}

// MARK: - Result
struct FeedItem: Codable {
    let feedID: String?
    let title: String?
    var urlString: String {
        String((feedID ?? "").dropFirst(5))
    }

    enum CodingKeys: String, CodingKey {
        case feedID = "feedId"
        case title = "title"
    }
}
