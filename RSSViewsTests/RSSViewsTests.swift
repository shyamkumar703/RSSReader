//
//  RSSViewsTests.swift
//  RSSViewsTests
//
//  Created by Shyam Kumar on 6/12/23.
//

import Combine
import RSSClient
import XCTest
@testable import RSSViews

final class RSSViewsTests: XCTestCase {
    func testCategoriesViewModel_ConsumesCategoriesFromClient() {
        let categories = [
            RSSCategory(id: 1, title: "All", unreadCount: 60),
            RSSCategory(id: 2, title: "Tech", unreadCount: 40),
            RSSCategory(id: 3, title: "News", unreadCount: 20),
            RSSCategory(id: 4, title: "Politics", unreadCount: 0)
        ]

        let model = CategoriesViewModel(
            rssClient: RSSClient(
                categories: {
                    Just(categories)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                },
                feedFor: { _ in fatalError() },
                markAs: { _, _ in fatalError() },
                toggleStar: { _ in fatalError() },
                markCategoryAsRead: { _ in fatalError() }
            ),
            storageClient: .empty
        )

        XCTAssertEqual(model.categories.elements, categories)
    }
    
    func testCategoriesWithClashingIdentifiers_DoesntCrash() {
        let categories = [
            RSSCategory(id: 1, title: "All", unreadCount: 60),
            RSSCategory(id: 1, title: "Tech", unreadCount: 40),
            RSSCategory(id: 3, title: "News", unreadCount: 20),
            RSSCategory(id: 4, title: "Politics", unreadCount: 0)
        ]

        let model = CategoriesViewModel(
            rssClient: RSSClient(
                categories: {
                    Just(categories)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                },
                feedFor: { _ in fatalError() },
                markAs: { _, _ in fatalError() },
                toggleStar: { _ in fatalError() },
                markCategoryAsRead: { _ in fatalError() }
            ),
            storageClient: .empty
        )
    }
    
    func testCategoriesViewModel_HandlesCategorySelectionCorrectly() {
        let categories = [
            RSSCategory(id: 1, title: "All", unreadCount: 3)
        ]
        
        let model = CategoriesViewModel(
            rssClient: RSSClient(
                categories: {
                    Just(categories)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                },
                feedFor: { _ in
                    Just(
                        FeedResponse(
                            total: 4,
                            entries: [
                                FeedEntry.read(id: 1),
                                FeedEntry.unread(id: 2),
                                FeedEntry.unread(id: 3),
                                FeedEntry.starred(id: 4)
                            ]
                        )
                    )
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                },
                markAs: { _, _ in fatalError() },
                toggleStar: { _ in fatalError() },
                markCategoryAsRead: { _ in fatalError() }
            ),
            storageClient: .empty
        )
        
        XCTAssertNil(model.destination)
        
        model.categoryTapped(category: categories[0])
        XCTAssertNotNil(model.destination)
        switch model.destination {
        case .feedView(let feedVM):
            feedVM.onArticleMarkedAsRead(1)
            feedVM.onArticleMarkedAsRead(1)
            XCTAssertEqual(model.categories[0].unreadCount, 1)
            
            feedVM.onArticleMarkedAsUnread(1)
            feedVM.onArticleMarkedAsUnread(1)
            XCTAssertEqual(model.categories[0].unreadCount, 3)
            
            feedVM.onArticleMarkedAsRead(1)
            feedVM.onArticleMarkedAsRead(1)
            feedVM.onArticleMarkedAsRead(1)
            XCTAssertEqual(model.categories[0].unreadCount, 0)
            
            feedVM.onArticleMarkedAsRead(1)
            XCTAssertEqual(model.categories[0].unreadCount, 0)
        default:
            XCTFail()
        }
    }
    
    func testCategoryFeedViewModel_HandlesActionsCorrectly() {
        let categories = [
            RSSCategory(id: 1, title: "All", unreadCount: 3)
        ]
        
        var markAPICallCount = 0
        var toggleStarAPICallCount = 0
        
        let model = CategoriesViewModel(
            rssClient: RSSClient(
                categories: {
                    Just(categories)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                },
                feedFor: { _ in
                    Just(
                        FeedResponse(
                            total: 4,
                            entries: [
                                FeedEntry.read(id: 1),
                                FeedEntry.unread(id: 2),
                                FeedEntry.unread(id: 3),
                                FeedEntry.starred(id: 4)
                            ]
                        )
                    )
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                },
                markAs: { _, _ in  markAPICallCount += 1 },
                toggleStar: { _ in toggleStarAPICallCount += 1 },
                markCategoryAsRead: { _ in fatalError() }
            ),
            storageClient: .empty
        )
        
        model.categoryTapped(category: categories[0])
        
        switch model.destination {
        case .feedView(let feedVM):
            // MARK: - Testing status changes
            feedVM.perform(action: .markAsUnread, on: 1)
            XCTAssertEqual(feedVM.feed[id: 1]?.status, .unread)
            
            // should not create an API call, status is the same as before
            feedVM.perform(action: .markAsUnread, on: 1)
            XCTAssertEqual(feedVM.feed[id: 1]?.status, .unread)
            
            feedVM.perform(action: .markAsRead, on: 2)
            XCTAssertEqual(feedVM.feed[id: 2]?.status, .read)
            
            // should not create an API call, status is the same as before
            feedVM.perform(action: .markAsRead, on: 2)
            XCTAssertEqual(feedVM.feed[id: 2]?.status, .read)
            
            XCTAssertEqual(markAPICallCount, 2)
            
            // MARK: - Testing star changes
            feedVM.perform(action: .markAsStarred, on: 1)
            XCTAssertEqual(feedVM.feed[id: 1]?.starred, true)
            
            // should not create an API call, status is the same as above
            feedVM.perform(action: .markAsStarred, on: 1)
            XCTAssertEqual(feedVM.feed[id: 1]?.starred, true)
            
            feedVM.perform(action: .markAsUnstarred, on: 4)
            XCTAssertEqual(feedVM.feed[id: 4]?.starred, false)
            
            // should not create an API call, status is the same as above
            feedVM.perform(action: .markAsUnstarred, on: 4)
            XCTAssertEqual(feedVM.feed[id: 4]?.starred, false)
            
            // Test nonexistent ID does not crash
            for action in CategoryFeedViewModel.SwipeAction.allCases {
                feedVM.perform(action: action, on: 6)
            }
        default:
            XCTFail()
        }
    }
    
    func testCategoryViewModel_HandlesMarkCategoryAsReadCorrectly() {
        let categories = [
            RSSCategory(id: 1, title: "All", unreadCount: 3)
        ]
        
        var markCategoryAsReadCalls = 0
        let model = CategoriesViewModel(
            rssClient: .init(
                categories: {
                    Just(categories)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                },
                feedFor: { _ in fatalError() },
                markAs: { _, _ in fatalError() },
                toggleStar: { _ in fatalError() },
                markCategoryAsRead: { _ in markCategoryAsReadCalls += 1 }
            ),
            storageClient: .empty
        )
        
        model.markAsReadTapped(id: 1)
        XCTAssertEqual(markCategoryAsReadCalls, 1)
        XCTAssertEqual(model.categories[id: 1]?.unreadCount, 0)
    }
}
