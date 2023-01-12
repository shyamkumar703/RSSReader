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
            if shouldToggleLoading { withAnimation { isLoading = true } }
        }
    }
}
