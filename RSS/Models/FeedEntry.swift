//
//  FeedEntry.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation

struct FeedResponse: Codable {
    var total: Int
    var entries: [FeedEntry]
}

struct FeedEntry: Codable, Identifiable {
    enum Status: String, Codable {
        case read
        case unread
        case removed
    }
    
    var id: Int
    var userId: Int // user_id
    var feedId: Int // feed_id
    var status: Status // fill out other cases
    var hash: String
    var title: String
    var url: String
    var commentsUrl: String // comments_url
    var publishedAt: String // published_at
    var createdAt: String // created_at
    var changedAt: String // changed_at
    var author: String
    var shareCode: String // share_code
    var starred: Bool
    var readingTime: Int?
    var feed: Feed
    var content: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case feedId = "feed_id"
        case status
        case hash
        case title
        case url
        case commentsUrl = "comments_url"
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case author
        case shareCode = "share_code"
        case starred
        case readingTime = "reading_time"
        case feed
        case content
    }
}
