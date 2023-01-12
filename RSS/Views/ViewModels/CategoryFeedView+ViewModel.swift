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
        @Published var feed = [FeedEntry]()
        
        func loadFeed(for category: Category?, with session: SessionManager) async {
            _ = await session.loadFeed(for: category)
        }
    }
}
