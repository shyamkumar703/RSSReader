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
        
        func loadFeed(for category: Category?, with dependencies: HasAPI) async {
            let result = await dependencies.api.call(with: GetFeedRequest(categoryId: category?.id))
            switch result {
            case .success(let feedResponse):
                withAnimation {
                    self.feed = feedResponse.entries
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
