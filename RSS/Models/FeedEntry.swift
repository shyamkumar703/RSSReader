//
//  FeedEntry.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import Foundation
import QueryBuilderSwiftUI

struct FeedResponse: Codable {
    var total: Int
    var entries: [FeedEntry]
}

final class FeedEntry: Codable, Identifiable, Equatable, Hashable, ObservableObject, Comparable, Queryable {
    enum Status: String, Codable, CaseIterable {
        case read
        case unread
        case removed
    }
    
    var id: Int
    var userId: Int // user_id
    var feedId: Int // feed_id
    @Published var status: Status // fill out other cases
    var hash: String
    var title: String
    var url: String
    var commentsUrl: String // comments_url
    var publishedAt: String // published_at
    var createdAt: String // created_at
    var changedAt: String // changed_at
    var author: String
    var shareCode: String // share_code
    @Published var starred: Bool
    var readingTime: Int?
    var feed: Feed
    var content: String
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    var date: Date {
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
    
    static func == (lhs: FeedEntry, rhs: FeedEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
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
    
    required init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
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
    
    static func < (lhs: FeedEntry, rhs: FeedEntry) -> Bool {
        lhs.date > rhs.date
    }
}

extension FeedEntry {
    static var queryableParameters: [PartialKeyPath<FeedEntry>: any IsComparable.Type] = [
        \.status: Status.self,
        \.date: Date.self,
        \.starred: Bool.self,
        \.feed: Feed.self
    ]
    
    static func stringFor(_ keypath: PartialKeyPath<FeedEntry>) -> String {
        switch keypath {
        case \.status: return "Status"
        case \.date: return "Date"
        case \.starred: return "Starred"
        case \.feed: return "Feed"
        default: return ""
        }
    }
    
    static func keypathFor(_ string: String) throws -> PartialKeyPath<FeedEntry> {
        switch string {
        case "Status": return \.status
        case "Date": return \.date
        case "Starred": return \.starred
        case "Feed": return \.feed
        default: throw FeedEntryError.invalidKeypathString
        }
    }
    
    enum FeedEntryError: Error {
        case invalidKeypathString
    }

}

extension FeedEntry.Status: IsComparable {
    static func getValidComparators() -> [QueryBuilderSwiftUI.Comparator] {
        [.equal, .notEqual]
    }
    
    func evaluate(comparator: QueryBuilderSwiftUI.Comparator, against value: any IsComparable) -> Bool {
        guard let value = value as? FeedEntry.Status else {
            return false
        }
        switch comparator {
        case .less:
            print("Status comparison does not support <, running != instead")
            return self != value
        case .greater:
            print("Status comparsion does not support >, running != instead")
            return self != value
        case .lessThanOrEqual:
            print("Status comparison does not support <=, running == instead")
            return self == value
        case .greaterThanOrEqual:
            print("Status comparison does not support >=, running == instead")
            return self == value
        case .equal:
            return self == value
        case .notEqual:
            return self != value
        }
    }
    
    static func createAssociatedViewModel(options: [(any IsComparable)], startingValue: (any IsComparable)?) -> StringComparableViewModel {
        return StringComparableViewModel(value: startingValue as? String, options: options)
    }
    
    func translateOption() -> any IsComparable { rawValue }
}
