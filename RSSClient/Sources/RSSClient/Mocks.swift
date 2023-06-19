//
//  Mocks.swift
//  
//
//  Created by Shyam Kumar on 6/11/23.
//

import Combine
import Foundation

extension RSSClient {
    public static var mock: Self {
        .init(
            categories: {
                Just([
                    RSSCategory(id: 1, title: "All", unreadCount: 20),
                    RSSCategory(id: 2, title: "Tech", unreadCount: 40),
                    RSSCategory(id: 3, title: "News", unreadCount: 60),
                    RSSCategory(id: 4, title: "Politics", unreadCount: 0)
                ])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            },
            feedFor: { id in
                Just(
                    FeedResponse(
                        total: 4,
                        entries: [
                            FeedEntry.read(id: 1),
                            FeedEntry.unread(id: 2),
                            FeedEntry.unread(id: 3),
                            FeedEntry.starred(id: 4)
                        ]
                    )
                )
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            },
            markAs: { _, _ in },
            toggleStar: { _ in },
            markCategoryAsRead: { _ in }
        )
    }
}

extension Feed {
    public static var mock: Self {
        .init(
            id: 0,
            userId: 0,
            feedUrl: "www.apple.com",
            siteUrl: "www.apple.com",
            title: "Feed Test",
            checkedAt: "",
            nextCheckAt: ""
        )
    }
}

extension FeedEntry {
    public static func read(id: Int) -> FeedEntry {
        .init(
            id: id,
            userId: 1,
            feedId: 1,
            status: .read,
            hash: "",
            title: "Test",
            url: "",
            commentsUrl: "www.apple.com",
            publishedAt: "",
            createdAt: "",
            changedAt: "",
            author: "",
            shareCode: "",
            starred: false,
            feed: .mock,
            content: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Turpis egestas integer eget aliquet nibh praesent tristique magna. Aliquet sagittis id consectetur purus ut faucibus pulvinar elementum. Elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique senectus. Nunc faucibus a pellentesque sit amet porttitor eget dolor. Nisl tincidunt eget nullam non nisi est sit amet. Enim nunc faucibus a pellentesque sit amet porttitor eget. A iaculis at erat pellentesque adipiscing. Suscipit tellus mauris a diam maecenas sed enim ut. Aliquam sem et tortor consequat id porta nibh. Tortor at risus viverra adipiscing at. Blandit cursus risus at ultrices mi tempus imperdiet nulla. Sit amet consectetur adipiscing elit pellentesque. Consequat ac felis donec et odio pellentesque. Sit amet cursus sit amet dictum. Nam aliquam sem et tortor consequat id porta
            """
        )
    }
    
    public static func unread(id: Int) -> FeedEntry {
        .init(
            id: id,
            userId: 1,
            feedId: 1,
            status: .unread,
            hash: "",
            title: "Test",
            url: "",
            commentsUrl: "https://www.apple.com",
            publishedAt: "",
            createdAt: "",
            changedAt: "",
            author: "",
            shareCode: "",
            starred: false,
            feed: .mock,
            content: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Turpis egestas integer eget aliquet nibh praesent tristique magna. Aliquet sagittis id consectetur purus ut faucibus pulvinar elementum. Elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique senectus. Nunc faucibus a pellentesque sit amet porttitor eget dolor. Nisl tincidunt eget nullam non nisi est sit amet. Enim nunc faucibus a pellentesque sit amet porttitor eget. A iaculis at erat pellentesque adipiscing. Suscipit tellus mauris a diam maecenas sed enim ut. Aliquam sem et tortor consequat id porta nibh. Tortor at risus viverra adipiscing at. Blandit cursus risus at ultrices mi tempus imperdiet nulla. Sit amet consectetur adipiscing elit pellentesque. Consequat ac felis donec et odio pellentesque. Sit amet cursus sit amet dictum. Nam aliquam sem et tortor consequat id porta
            """
        )
    }
    
    public static func starred(id: Int) -> FeedEntry {
        .init(
            id: id,
            userId: 1,
            feedId: 1,
            status: .unread,
            hash: "",
            title: "Test",
            url: "",
            commentsUrl: "www.apple.com",
            publishedAt: "",
            createdAt: "",
            changedAt: "",
            author: "",
            shareCode: "",
            starred: true,
            feed: .mock,
            content: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Turpis egestas integer eget aliquet nibh praesent tristique magna. Aliquet sagittis id consectetur purus ut faucibus pulvinar elementum. Elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique senectus. Nunc faucibus a pellentesque sit amet porttitor eget dolor. Nisl tincidunt eget nullam non nisi est sit amet. Enim nunc faucibus a pellentesque sit amet porttitor eget. A iaculis at erat pellentesque adipiscing. Suscipit tellus mauris a diam maecenas sed enim ut. Aliquam sem et tortor consequat id porta nibh. Tortor at risus viverra adipiscing at. Blandit cursus risus at ultrices mi tempus imperdiet nulla. Sit amet consectetur adipiscing elit pellentesque. Consequat ac felis donec et odio pellentesque. Sit amet cursus sit amet dictum. Nam aliquam sem et tortor consequat id porta
            """
        )
    }
}

extension RSSCategory {
    public static var mock: Self {
        .init(id: 2, title: "Tech", unreadCount: 40)
    }
}
