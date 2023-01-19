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
    func toggleStar(for entry: FeedEntry, in category: Category?) async
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
    
    func loadFeedLazy(for category: Category?, before date: Date, status: Set<FeedEntry.Status> = Set(FeedEntry.Status.allCases)) async -> Result<FeedResponse, RSSError> {
        let result = await dependencies.api.call(with: GetFeedLazyRequest(categoryId: category?.id, before: date, status: status))
        switch result {
        case .success(let feedResponse):
            withAnimation {
                let currentCategory = category ?? Category.example
                
                var newEntries = feedCategoryDictionary[currentCategory] ?? []
                newEntries += feedResponse.entries
                feedCategoryDictionary[currentCategory] = newEntries
                
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
            var newCategories = categories.sorted().map({ Category(id: $0.id, title: $0.title.capitalized) })
            await addCategoryUnreadCounts(categories: newCategories)
            let allCategory = Category.example
            allCategory.unreadCount = newCategories.reduce(0, { interim, category in interim + (category.unreadCount ?? 0) })
            newCategories.insert(allCategory, at: 0)
            withAnimation { self.categories = newCategories.sorted() }
            dependencies.localStorage.save(newCategories, for: .categories)
        case .failure(let error):
            print("Failure...\(error)")
        }
        return result
    }
    
    private func addCategoryUnreadCounts(categories: [Category]) async {
        let result = await dependencies.api.call(with: UnreadCountRequest())
        switch result {
        case .success(let response):
            await withTaskGroup(of: (Category, Int).self) { group in
                for category in categories {
                    group.addTask {
                        return await self.getUnreadCountFor(category: category, with: response.unreads)
                    }
                }
                
                for await (category, unread) in group {
                    category.unreadCount = unread
                }
            }
        case .failure(let error):
            print(error)
        }
    }
    
    private func getUnreadCountFor(category: Category, with unreads: [String: Int]) async -> (Category, Int) {
        let result = await dependencies.api.call(with: GetCategoryFeeds(categoryId: category.id))
        switch result {
        case .success(let feeds):
            var unreadCount = 0
            for feed in feeds {
                unreadCount += unreads[String(feed.id)] ?? 0
            }
            return (category, unreadCount)
        case .failure(let error):
            print(error)
            return (category, 0)
        }
    }
    
    func feedFor(category: Category?) -> [FeedEntry] {
        if let category = category {
            return feedCategoryDictionary[category] ?? []
        } else {
            return feedCategoryDictionary[Category.example] ?? []
        }
    }
    
    func toggleStar(for entry: FeedEntry, in category: Category?) async {
        // rework to add result in future
        _ = await dependencies.api.call(with: StarItemRequest(entryId: entry.id))
        _ = await loadFeed(for: category)
    }
}
