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
            categories: getCategories,
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
    
    private static func getCategories() -> AnyPublisher<[RSSCategory], Error> {
        let GenRequest = Request<IgnoreResponse, NoBody>.self
        guard let url = URL(string: "https://api.quicksplitapp.com/rss/categories") else {
            return Fail(error: RSSError.invalidURL).eraseToAnyPublisher()
        }
        
        guard let authHeader = GenRequest.generateBasicAuthHeader() else {
            return Fail(error: RSSError.generateAuthFailed).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Basic \(authHeader)", forHTTPHeaderField: "Authorization")
        
        return URLSession.DataTaskPublisher(request: urlRequest, session: .shared)
            .map { data, _ in data }
            .decode(type: [RSSCategory].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
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
        if feedResponse.entries.count < feedResponse.total {
            let requestsNeeded = feedResponse.entries.count / 10
            var publishers = [AnyPublisher<FeedResponse, Error>]()
            for offsetMultiple in 1...requestsNeeded {
                publishers.append(GenRequest.getFeed(categoryId, offset: offsetMultiple * 100).call())
            }
            
            Publishers.MergeMany(publishers)
                .map { $0.entries }
                .collect()
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { feedEntries in
                        let fullEntries = feedResponse.entries + feedEntries.flatMap({ $0 })
                        publisher.send(
                            FeedResponse(
                                total: feedResponse.total,
                                entries: fullEntries
                            )
                        )
                        
                    }
                )
                .store(in: &bag)
        }
    }
}
