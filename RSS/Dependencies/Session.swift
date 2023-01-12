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
    var dependencies: AllDependencies
    @Published var feedCategoryDictionary = [Category: [FeedEntry]]()
    @Published var categories = [Category]()
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
        self.categories = dependencies.localStorage.read(from: .categories, type: Array<Category>.self) ?? []
        self.feedCategoryDictionary = dependencies.localStorage.read(from: .feedDictionary, type: [Category: [FeedEntry]].self) ?? [:]
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
                
                dependencies.localStorage.save(feedCategoryDictionary, for: .feedDictionary)
            }
        case .failure(let error):
            print("error: \(error)")
        }
        return result
    }
    
    func loadCategories() async -> Result<Array<Category>, RSSError>  {
        let result = await dependencies.api.call(with: GetCategoriesRequest())
        switch result {
        case .success(let categories):
            let newCategories = categories.sorted().map({ Category(id: $0.id, title: $0.title.capitalized) })
            withAnimation { self.categories = newCategories }
            dependencies.localStorage.save(newCategories, for: .categories)
        case .failure(let error):
            print("Failure...\(error)")
        }
        return result
    }
    
    func feedFor(category: Category?) -> [FeedEntry] {
        if let category = category {
            return feedCategoryDictionary[category] ?? []
        } else {
            return feedCategoryDictionary[Category.example] ?? []
        }
    }
}
