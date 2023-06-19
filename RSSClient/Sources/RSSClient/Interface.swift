//GenRequest.getFeed(categoryId, offset: offsetMultiple * 100).callTyped()//  Interface.swift
//  
//
//  Created by Shyam Kumar on 6/11/23.
//

import Combine
import Foundation

public struct RSSClient {
    public var categories: () -> AnyPublisher<[RSSCategory], Error>
    public var feedFor: (Int?) -> AnyPublisher<FeedResponse, Error>
    // Fire and forget
    /// entryIds, status
    public var markAs: ([Int], FeedEntry.Status) -> Void
    /// entryId
    public var toggleStar: (Int) -> Void
    /// categoryId
    public var markCategoryAsRead: (Int) -> Void
    
    public static var bag = Set<AnyCancellable>()
    
    public init(
        categories: @escaping () -> AnyPublisher<[RSSCategory], Error>,
        feedFor: @escaping (Int?) -> AnyPublisher<FeedResponse, Error>,
        markAs: @escaping ([Int], FeedEntry.Status) -> Void,
        toggleStar: @escaping (Int) -> Void,
        markCategoryAsRead: @escaping (Int) -> Void
    ) {
        self.categories = categories
        self.feedFor = feedFor
        self.markAs = markAs
        self.toggleStar = toggleStar
        self.markCategoryAsRead = markCategoryAsRead
    }
}
