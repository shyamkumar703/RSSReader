//
//  Session.swift
//  RSS
//
//  Created by Shyam Kumar on 1/12/23.
//

import Foundation
import SwiftUI

protocol Session {
    func markAs(status: FeedEntry.Status, item: FeedEntry, category: Category?) async
    func loadFeed(for category: Category?) async -> Result<FeedResponse, RSSError>
    func loadCategories() async -> Result<Array<Category>, RSSError>
    func feedFor(category: Category?) -> [FeedEntry]
}

@MainActor class SessionManager: ObservableObject {
    private var dependencies: AllDependencies
    @Published var feed = [FeedEntry]()
    @Published var feedCategoryDictionary = [Category: [FeedEntry]]()
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
    }
    
    func markAs(status: FeedEntry.Status, item: FeedEntry, category: Category?) async {
        _ = await dependencies.api.call(with: MarkItemRequest(entryIds: [item.id], status: status))
        Task { [weak self] in
            await self?.loadFeed(for: category)
        }
    }
    
    func loadFeed(for category: Category?) async -> Result<FeedResponse, RSSError> {
        let result = await dependencies.api.call(with: GetFeedRequest(categoryId: category?.id))
        switch result {
        case .success(let feedResponse):
            withAnimation {
                if let category = category {
                    feedCategoryDictionary[category] = feedResponse.entries
                } else {
                    feedCategoryDictionary[Category.example] = feedResponse.entries
                }
            }
        case .failure(let error):
            print("error: \(error)")
        }
        return result
    }
    
    func loadCategories() async -> Result<Array<Category>, RSSError>  {
        return await dependencies.api.call(with: GetCategoriesRequest())
    }
    
    func feedFor(category: Category?) -> [FeedEntry] {
        if let category = category {
            return feedCategoryDictionary[category] ?? []
        } else {
            return feedCategoryDictionary[Category.example] ?? []
        }
    }
}
