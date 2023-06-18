//
//  Interface.swift
//  
//
//  Created by Shyam Kumar on 6/13/23.
//

import Combine
import Foundation
import IdentifiedCollections
import RSSClient

public struct StorageClient {
    var categories: IdentifiedArrayOf<RSSCategory> = .init()
    var feeds: IdentifiedArrayOf<FeedResponse> = .init()
    
    public var storeCategoriesToDisk: ([RSSCategory]) -> Void
    public var readCategoriesFromDisk: () -> [RSSCategory]
    
    public var storeFeedsToDisk: ([FeedResponse]) -> Void
    public var readFeedsFromDisk: () -> [FeedResponse]
    
    public init(
        storeCategoriesToDisk: @escaping ([RSSCategory]) -> Void,
        readCategoriesFromDisk: @escaping () -> [RSSCategory],
        storeFeedsToDisk: @escaping ([FeedResponse]) -> Void,
        readFeedsFromDisk: @escaping () -> [FeedResponse]
    ) {
        self.storeCategoriesToDisk = storeCategoriesToDisk
        self.readCategoriesFromDisk = readCategoriesFromDisk
        self.storeFeedsToDisk = storeFeedsToDisk
        self.readFeedsFromDisk = readFeedsFromDisk
        
        self.categories = .init(uniqueElements: readCategoriesFromDisk().unique())
        self.feeds = .init(uniqueElements: readFeedsFromDisk().unique())
    }
    
    public func getAllCategories() -> IdentifiedArrayOf<RSSCategory> {
        .init(uniqueElements: readCategoriesFromDisk().unique())
    }
    
    public func getFeedFor(categoryId id: Int) -> FeedResponse? {
        readFeedsFromDisk().first(where: { $0.id == id })
    }
    
    public mutating func updateFeed(for categoryId: Int, feedResponse: inout FeedResponse) {
        feedResponse.categoryId = categoryId
        feeds[id: categoryId] = feedResponse
        storeFeedsToDisk(self.feeds.elements)
    }
    
    public mutating func updateCategories(_ categories: [RSSCategory]) {
        self.categories = .init(uniqueElements: categories.unique())
        storeCategoriesToDisk(self.categories.elements)
    }
    
    public mutating func mark(categoryId: Int?, entries: [Int], as status: FeedEntry.Status) {
        modifyEntry(categoryId: categoryId, entries: entries) { feedEntry in
            feedEntry.status = status
        }
    }
    
    public mutating func toggleStar(categoryId: Int?, entry: Int) {
        modifyEntry(categoryId: categoryId, entries: [entry]) { feedEntry in
            feedEntry.starred.toggle()
        }
    }
    
    public mutating func markCategoryAsRead(categoryId: Int) {
        guard let index = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        var categoryCopy = categories[index]
        categoryCopy.unreadCount = 0
        categories.remove(at: index)
        categories.insert(categoryCopy, at: index)
        storeCategoriesToDisk(categories.elements)
    }
    
    private mutating func modifyEntry(categoryId: Int?, entries: [Int], modification: (inout FeedEntry) -> Void) {
        guard let categoryId,
              let _ = categories[id: categoryId] else { return }
        
        for entry in entries {
            guard var feed = feeds[id: categoryId] else { continue }
            guard let index = feed.entries.firstIndex(where: { $0.id == entry }) else { continue }
            var feedEntryCopy = feed.entries[index]
            modification(&feedEntryCopy)
            feed.entries.remove(at: index)
            feed.entries.insert(feedEntryCopy, at: index)
            feeds[id: categoryId] = feed
        }
    }
}

// MARK: - Helpers
extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
