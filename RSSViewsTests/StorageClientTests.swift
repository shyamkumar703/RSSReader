//
//  StorageClientTests.swift
//  RSSViewsTests
//
//  Created by Shyam Kumar on 6/13/23.
//

import Combine
import RSSClient
import XCTest
@testable import RSSViews

final class StorageClientTests: XCTestCase {
    func testStorageClient_AddingCategoriesWorksCorrectly() {
        var categories: [RSSCategory] = []
        let categoriesToSave: [RSSCategory] = [
            .init(id: 2, title: "Tech", unreadCount: 40),
            .init(id: 3, title: "Tech", unreadCount: 40)
        ]
        
        let storageClient: StorageClient = .init(
            storeCategoriesToDisk: { categories = $0 },
            readCategoriesFromDisk: { categories },
            storeFeedsToDisk: { _ in fatalError() },
            readFeedsFromDisk: { [] } // called on init
        )
        
        XCTAssertEqual(storageClient.categories.count, 0)
        storageClient.storeCategoriesToDisk(categoriesToSave)
        XCTAssertEqual(storageClient.readCategoriesFromDisk(), categoriesToSave)
    }
    
    func testStorageClient_AddingFeedsWorksCorrectly() {
        var feed: [FeedResponse] = []
        var feedResponseToSave = FeedResponse(
            total: 2,
            entries: [.read(id: 1), .unread(id: 2)]
        )
        
        var storageClient: StorageClient = .init(
            storeCategoriesToDisk: { _ in },
            readCategoriesFromDisk: { [] },
            storeFeedsToDisk: { feed = $0 },
            readFeedsFromDisk: { feed } // called on init
        )
        
        XCTAssertTrue(storageClient.categories.isEmpty)
        XCTAssertTrue(storageClient.feeds.isEmpty)
        
        storageClient.updateCategories([
            .init(id: 2, title: "Tech", unreadCount: 40)
        ])
        storageClient.updateFeed(for: 2, feedResponse: &feedResponseToSave)
        
        XCTAssertEqual(feed.count, 1)
        XCTAssertEqual(feed[0], feedResponseToSave)
        XCTAssertEqual(storageClient.feeds.count, 1)
        XCTAssertEqual(storageClient.feeds[0], feedResponseToSave)
    }
    
    func testStorageClient_MarkStatusWorksAsExpected() {
        var storageClient: StorageClient = .empty
        var feedResponse = FeedResponse(
            total: 2,
            entries: [.read(id: 1), .unread(id: 2)]
        )
        storageClient.updateCategories([
            .init(id: 2, title: "Tech", unreadCount: 40)
        ])
        
        storageClient.updateFeed(for: 2, feedResponse: &feedResponse)
        XCTAssertEqual(feedResponse.categoryId, 2)
        
        storageClient.mark(categoryId: 2, entries: [1], as: .unread)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[0].id, 1)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[0].status, .unread)
        
        storageClient.mark(categoryId: 2, entries: [2], as: .read)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[1].id, 2)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[1].status, .read)
        
        storageClient.mark(categoryId: 2, entries: [1, 2], as: .removed)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[0].id, 1)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[1].id, 2)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[0].status, .removed)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[1].status, .removed)
    }
    
    func testStorageClient_ToggleStarWorksAsExpected() {
        var storageClient: StorageClient = .empty
        var feedResponse = FeedResponse(
            total: 2,
            entries: [.read(id: 1), .starred(id: 2)]
        )
        storageClient.updateCategories([
            .init(id: 2, title: "Tech", unreadCount: 40)
        ])
        storageClient.updateFeed(for: 2, feedResponse: &feedResponse)
        
        storageClient.toggleStar(categoryId: 2, entry: 1)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[0].starred, true)
        
        storageClient.toggleStar(categoryId: 2, entry: 2)
        XCTAssertEqual(storageClient.feeds[id: 2]?.entries[1].starred, false)
    }
}
