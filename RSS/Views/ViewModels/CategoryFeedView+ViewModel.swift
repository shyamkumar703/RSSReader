//
//  CategoryFeedView+ViewModel.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftUI
import Foundation

extension CategoryFeedView {
    @MainActor class ViewModel: ObservableObject {
        @Published var isLoading = false
        
        func loadFeed(for category: Category?, with session: SessionManager) async {
            let shouldToggleLoading = session.feedFor(category: category).isEmpty
            if shouldToggleLoading { withAnimation { isLoading = true } }
            _ = await session.loadFeed(for: category)
            if shouldToggleLoading { withAnimation { isLoading = false } }
        }
        
        func loadItems(for category: Category?, before date: Date, options: FilterOptions = .all, with session: SessionManager) async {
            guard !isLoading else { return }
            withAnimation { isLoading = true }
            switch options {
            case .all, .starred:
                _ = await session.loadFeedLazy(for: category, before: date)
            case .unread:
                _ = await session.loadFeedLazy(for: category, before: date, status: [.unread])
            }
            withAnimation { isLoading = false }
        }
    }
}
