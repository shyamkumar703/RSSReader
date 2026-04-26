//
//  Live.swift
//  
//
//  Created by Shyam Kumar on 6/11/23.
//

import Combine
import Foundation
import RSSClient

extension RSSClient {
    public static var live: Self {
        let GenRequest = Request<IgnoreResponse, NoBody>.self
        var markAsCancellable: AnyCancellable?
        var toggleStarCancellable: AnyCancellable?
        var markCategoryAsReadCancellable: AnyCancellable?
        
        return .init(
            categories: GenRequest.getCategories.call,
            feedFor: { catId, offset in getFeedFor(categoryId: catId ?? 0, offset: offset) },
            markAs: { entries, status in
                markAsCancellable = GenRequest.mark(entryIds: entries, status: status)
                    .call()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
            },
            toggleStar: {
                toggleStarCancellable = GenRequest.star($0)
                    .call()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
            },
            markCategoryAsRead: {
                markCategoryAsReadCancellable = GenRequest.markCategoryAsRead(categoryId: $0)
                    .call()
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
            }
        )
    }
    
    private static func getFeedFor(categoryId: Int, offset: Int) -> AnyPublisher<FeedResponse, Error> {
        Request<IgnoreResponse, NoBody>.getFeed(categoryId, offset: offset).call()
    }
}
