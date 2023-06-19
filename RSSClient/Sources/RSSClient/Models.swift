//
//  Models.swift
//  
//
//  Created by Shyam Kumar on 6/11/23.
//

import Foundation

public struct RSSCategory: Codable, Identifiable, Comparable, Hashable {
    public var id: Int
    public var title: String
    public var unreadCount: Int?
    
    public init(id: Int, title: String, unreadCount: Int? = 0) {
        self.id = id
        self.title = title
        self.unreadCount = unreadCount
    }
    
    public static func < (lhs: RSSCategory, rhs: RSSCategory) -> Bool {
        (lhs.unreadCount ?? 0) > (rhs.unreadCount ?? 0)
    }
    
    public static func == (lhs: RSSCategory, rhs: RSSCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct FeedResponse: Codable, Identifiable, Equatable, Hashable {
    public var id: Int {
        categoryId ?? UUID().uuidString.hashValue
    }
    
    public var total: Int
    public var entries: [FeedEntry]
    public var categoryId: Int?
    
    public init(total: Int, entries: [FeedEntry]) {
        self.total = total
        self.entries = entries
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct FeedEntry: Codable, Identifiable, Equatable, Hashable, Comparable {
    public enum Status: String, Codable, CaseIterable {
        case read
        case unread
        case removed
    }
    
    public var id: Int
    public var userId: Int // user_id
    public var feedId: Int // feed_id
    public var status: Status // fill out other cases
    public var hash: String
    public var title: String
    public var url: String
    public var commentsUrl: String // comments_url
    public var publishedAt: String // published_at
    public var createdAt: String // created_at
    public var changedAt: String // changed_at
    public var author: String
    public var shareCode: String // share_code
    public var starred: Bool
    public var readingTime: Int?
    public var feed: Feed
    public var content: String
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    public var date: Date {
        dateFormatter.date(from: publishedAt) ?? Date()
    }
    
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
    
    public static func == (lhs: FeedEntry, rhs: FeedEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(
        id: Int,
        userId: Int,
        feedId: Int,
        status: FeedEntry.Status,
        hash: String,
        title: String,
        url: String,
        commentsUrl: String,
        publishedAt: String,
        createdAt: String,
        changedAt: String,
        author: String,
        shareCode: String,
        starred: Bool,
        readingTime: Int? = nil,
        feed: Feed,
        content: String
    ) {
        self.id = id
        self.userId = userId
        self.feedId = feedId
        self.status = status
        self.hash = hash
        self.title = title
        self.url = url
        self.commentsUrl = commentsUrl
        self.publishedAt = publishedAt
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.author = author
        self.shareCode = shareCode
        self.starred = starred
        self.readingTime = readingTime
        self.feed = feed
        self.content = content
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        feedId = try container.decode(Int.self, forKey: .feedId)
        status = try container.decode(FeedEntry.Status.self, forKey: .status)
        hash = try container.decode(String.self, forKey: .hash)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)
        commentsUrl = try container.decode(String.self, forKey: .commentsUrl)
        publishedAt = try container.decode(String.self, forKey: .publishedAt)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        changedAt = try container.decode(String.self, forKey: .changedAt)
        author = try container.decode(String.self, forKey: .author)
        shareCode = try container.decode(String.self, forKey: .shareCode)
        starred = try container.decode(Bool.self, forKey: .starred)
        readingTime = try container.decode(Int?.self, forKey: .readingTime)
        feed = try container.decode(Feed.self, forKey: .feed)
        content = try container.decode(String.self, forKey: .content)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(feedId, forKey: .feedId)
        try container.encode(status, forKey: .status)
        try container.encode(hash, forKey: .hash)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(commentsUrl, forKey: .commentsUrl)
        try container.encode(publishedAt, forKey: .publishedAt)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(changedAt, forKey: .changedAt)
        try container.encode(author, forKey: .author)
        try container.encode(shareCode, forKey: .shareCode)
        try container.encode(starred, forKey: .starred)
        try container.encode(readingTime, forKey: .readingTime)
        try container.encode(feed, forKey: .feed)
        try container.encode(content, forKey: .content)
    }
    
    public static func < (lhs: FeedEntry, rhs: FeedEntry) -> Bool {
        lhs.date > rhs.date
    }
}

public struct Feed: Codable, Identifiable {
   public var id: Int
   public var userId: Int // user_id
   public var feedUrl: String // feed_url
   public var siteUrl: String // site_url
   public var title: String
   public var checkedAt: String // checked_at
   public var nextCheckAt: String // next_check_at
    
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

public enum RSSError: Error {
    case invalidURL
    case generateAuthFailed
    case requestFailed(String)
    case decodingFailed
}
