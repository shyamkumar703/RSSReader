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
            feedFor: { getFeedFor(categoryId: $0 ?? 0) },
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
    
    private static func getFeedFor(categoryId: Int) -> AnyPublisher<FeedResponse, Error> {
        let publisher = PassthroughSubject<FeedResponse, Error>()
        let GenRequest = Request<IgnoreResponse, NoBody>.self
        GenRequest.getFeed(categoryId).call()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { feedResponse in
                    publisher.send(feedResponse)
                    handleInitialFeedResponse(categoryId: categoryId, feedResponse: feedResponse, publisher: publisher)
                }
            )
            .store(in: &bag)
        return publisher.eraseToAnyPublisher()
    }
    
    private static func handleInitialFeedResponse(categoryId: Int, feedResponse: FeedResponse, publisher: PassthroughSubject<FeedResponse, Error>) {
        let GenRequest = Request<IgnoreResponse, NoBody>.self
        let remaining = feedResponse.total - feedResponse.entries.count
        guard remaining > 0 else { return }

        let pageSize = 100
        let requestsNeeded = Int(ceil(Double(remaining) / Double(pageSize)))
        var publishers = [AnyPublisher<FeedResponse, Error>]()
        for page in 1...requestsNeeded {
            let offset = feedResponse.entries.count + (page - 1) * pageSize
            publishers.append(GenRequest.getFeed(categoryId, offset: offset).call())
        }

        Publishers.MergeMany(publishers)
            .map { $0.entries }
            .collect()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        publisher.send(completion: .failure(error))
                    }
                },
                receiveValue: { feedEntries in
                    let allEntries = (feedResponse.entries + feedEntries.flatMap { $0 })
                        .sorted { $0.date > $1.date }
                    publisher.send(FeedResponse(total: feedResponse.total, entries: allEntries))
                }
            )
            .store(in: &bag)
    }
}
