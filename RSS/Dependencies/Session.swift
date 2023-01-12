//
//  Session.swift
//  RSS
//
//  Created by Shyam Kumar on 1/12/23.
//

import Foundation
import SwiftUI

protocol Session {
    func markAs(status: FeedEntry.Status, item: FeedEntry) async
    func loadFeed(for category: Category?) async -> Result<FeedResponse, RSSError>
    func loadCategories() async -> Result<Array<Category>, RSSError>
}

@MainActor class SessionManager: ObservableObject {
    private var dependencies: AllDependencies
    @Published var feed = [FeedEntry]()
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
    }
    
    func markAs(status: FeedEntry.Status, item: FeedEntry) async {
        _ = await dependencies.api.call(with: MarkItemRequest(entryIds: [item.id], status: status))
        Task { [weak self] in
            await self?.loadFeed(for: nil)
        }
    }
    
    func loadFeed(for category: Category?) async -> Result<FeedResponse, RSSError> {
        let result = await dependencies.api.call(with: GetFeedRequest(categoryId: category?.id))
        switch result {
        case .success(let feedResponse):
            withAnimation { feed = feedResponse.entries }
        case .failure(let error):
            print("error: \(error)")
        }
        return result
    }
    
    func loadCategories() async -> Result<Array<Category>, RSSError>  {
        return await dependencies.api.call(with: GetCategoriesRequest())
    }
}
