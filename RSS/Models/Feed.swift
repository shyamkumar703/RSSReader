//
//  Feed.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct Feed: Codable, Identifiable {
    var id: Int
    var userId: Int // user_id
    var feedUrl: String // feed_url
    var siteUrl: String // site_url
    var title: String
    var checkedAt: String // checked_at
    var nextCheckAt: String // next_check_at
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case feedUrl = "feed_url"
        case siteUrl = "site_url"
        case title
        case checkedAt = "checked_at"
        case nextCheckAt = "next_check_at"
    }
}

extension Feed {
    struct Category: Codable, Identifiable {
        var id: Int
        var title: String
        var userId: Int // user_id
        
        static var example = Category(id: Int.min, title: "All", userId: 1)
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case userId = "user_id"
        }
    }
}
