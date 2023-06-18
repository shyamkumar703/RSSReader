//
//  CategoryFeedView.swift
//  RSSViews
//
//  Created by Shyam Kumar on 6/11/23.
//

import Combine
import IdentifiedCollections
import RSSClient
import SwiftUI
import SwiftUINavigation
import XCTestDynamicOverlay

public class CategoryFeedViewModel: ObservableObject {
    var rssClient: RSSClient
    var storageClient: StorageClient
    var category: RSSCategory?
    var onArticleMarkedAsRead: (Int?) -> Void = unimplemented("CategoryFeedViewModel.onArticleMarkedAsRead")
    var onArticleMarkedAsUnread: (Int?) -> Void = unimplemented("CategoryFeedViewModel.onArticleMarkedAsUnread")

    @Published
    var feed = IdentifiedArrayOf<FeedEntry>()
    
    @Published
    var destination: Destination? {
        didSet {
            self.bind()
        }
    }
    
    public enum Destination {
        case article(ArticleViewModel)
    }
    
    @Published
    var filter: FilterOption = .all
    
    @Published
    var searchText: String = ""
    
    enum FilterOption: String, CaseIterable {
        case unread = "Unread"
        case starred = "Starred"
        case all = "All"
    }
    
    var navigationTitle: String {
        category?.title ?? "All"
    }
    
    // MARK: - Cancellables
    var rssClientCancellable: AnyCancellable?
    
    public init(
        rssClient: RSSClient,
        storageClient: StorageClient,
        category: RSSCategory? = nil,
        destination: Destination? = nil,
        onArticleMarkedAsRead: ((Int?) -> Void)? = nil,
        onArticleMarkedAsUnread: ((Int?) -> Void)? = nil
    ) {
        self.rssClient = rssClient
        self.storageClient = storageClient
        self.category = category
        self.destination = destination
        if let onArticleMarkedAsRead { self.onArticleMarkedAsRead = onArticleMarkedAsRead }
        if let onArticleMarkedAsUnread { self.onArticleMarkedAsUnread = onArticleMarkedAsUnread }
        if let category {
            self.feed = .init(uniqueElements: storageClient.getFeedFor(categoryId: category.id)?.entries.unique() ?? [])
        }
        self.refresh()
        
        self.bind()
    }
    
    private func bind() {
        guard let destination else { return }
        switch destination {
        case .article(let articleVM):
            articleVM.onToggleStar = { [weak self] isStarred in
                self?.feed[id: articleVM.feedEntry.id]?.starred = isStarred
            }
        }
    }
    
    // MARK: - Helpers
    func tertiaryTitleText(for feedItem: FeedEntry) -> String {
        var startTitle = feedItem.feed.title
        if let readTime = feedItem.readingTime {
            startTitle += " · \(readTime) minute read"
        }
        return startTitle
    }
    
    func bottomTitleText(for feedItem: FeedEntry) -> String? {
        feedItem.date.timePassed()
    }
    
    enum SwipeAction: CaseIterable {
        case markAsRead
        case markAsUnread
        case markAsStarred
        case markAsUnstarred
    }
    
    func leadingSwipeAction(for feedEntryId: Int) -> SwipeAction {
        guard let feedEntry = feed[id: feedEntryId] else { return .markAsStarred }
        return feedEntry.starred ? .markAsUnstarred : .markAsStarred
    }
    
    func trailingSwipeAction(for feedEntryId: Int) -> SwipeAction {
        guard let feedEntry = feed[id: feedEntryId] else { return .markAsRead }
        return feedEntry.status == .read ? .markAsUnread : .markAsRead
    }
    
    func perform(action: SwipeAction, on feedEntryId: Int) {
        guard let feedEntry = feed[id: feedEntryId] else { return }
        switch action {
        case .markAsRead:
            guard feedEntry.status != .read else { return }
            feed[id: feedEntryId]?.status = .read
            rssClient.markAs([feedEntryId], .read)
            onArticleMarkedAsRead(category?.id)
        case .markAsUnread:
            guard feedEntry.status != .unread else { return }
            feed[id: feedEntryId]?.status = .unread
            rssClient.markAs([feedEntryId], .unread)
            onArticleMarkedAsUnread(category?.id)
        case .markAsStarred:
            guard !feedEntry.starred else { return }
            feed[id: feedEntryId]?.starred = true
            rssClient.toggleStar(feedEntryId)
        case .markAsUnstarred:
            guard feedEntry.starred else { return }
            feed[id: feedEntryId]?.starred = false
            rssClient.toggleStar(feedEntryId)
        }
    }
    
    func feedEntryTapped(id: Int) {
        guard let feedEntry = feed[id: id] else { return }
        self.destination = .article(
            ArticleViewModel(feedEntry: feedEntry, rssClient: rssClient)
        )
        
        // TODO: - Control dependency
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.perform(action: .markAsRead, on: id)
        }
    }
    
    func getFeed() -> IdentifiedArrayOf<FeedEntry> {
        switch filter {
        case .all: return entriesMatchingSearchTerm(feed)
        case .unread: return entriesMatchingSearchTerm(feed.filter({ $0.status == .unread }))
        case .starred: return entriesMatchingSearchTerm(feed.filter({ $0.starred }))
        }
    }
    
    private func entriesMatchingSearchTerm(_ feed: IdentifiedArrayOf<FeedEntry>) -> IdentifiedArrayOf<FeedEntry> {
        if searchText.isEmpty {
            return feed
        } else {
            return feed.filter({
                $0.author.contains(searchText) || $0.feed.title.contains(searchText) || $0.title.contains(searchText)
            })
        }
    }
    
    func refresh() {
        self.rssClientCancellable = self.rssClient.feedFor(self.category?.id).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] feedResponse in
                self?.feed = IdentifiedArray(uniqueElements: feedResponse.entries.unique())
                var feedResponseCopy = feedResponse
                self?.storageClient.updateFeed(for: self?.category?.id ?? 0, feedResponse: &feedResponseCopy)
            }
        )
    }
}

public struct CategoryFeedView: View {
    @ObservedObject var model: CategoryFeedViewModel
    @Environment(\.refresh) var refresh
    
    public init(model: CategoryFeedViewModel) {
        self.model = model
    }
    
    public var body: some View {
        List {
            ForEach(model.getFeed()) { feedItem in
                HStack {
                    HStack(alignment: .firstTextBaseline) {
                        HStack(alignment: .center) {
                            if feedItem.starred {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.primary)
                                    .frame(width: 12, height: 12)
                            }
                            
                            if feedItem.status == .unread {
                                Circle()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(feedItem.title)
                                .font(.subheadline)
                            
                            if !feedItem.author.isEmpty {
                                Text(feedItem.author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Text(model.tertiaryTitleText(for: feedItem))
                                .font(.caption)
                                .foregroundColor(.secondary.opacity(0.75))
                            
                            if let bottomTitleText = model.bottomTitleText(for: feedItem) {
                                Text(bottomTitleText)
                                    .font(.caption2)
                                    .foregroundColor(.secondary.opacity(0.75))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                          .font(Font.system(.footnote).weight(.bold))
                          .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    model.feedEntryTapped(id: feedItem.id)
                }
                .swipeActions(edge: .leading) {
                    switch model.leadingSwipeAction(for: feedItem.id) {
                    case .markAsUnstarred:
                        Button {
                            withAnimation {
                                model.perform(action: .markAsUnstarred, on: feedItem.id)
                            }
                        } label: {
                            Label("Unstar", systemImage: "star.slash.fill")
                                .labelStyle(.iconOnly)
                        }
                        .tint(.red)
                    case .markAsStarred:
                        Button {
                            withAnimation {
                                model.perform(action: .markAsStarred, on: feedItem.id)
                            }
                        } label: {
                            Label("Star", systemImage: "star.fill")
                                .labelStyle(.iconOnly)
                        }
                        .tint(.yellow)
                    default:
                        EmptyView()
                    }
                }
                .swipeActions(edge: .trailing) {
                    switch model.trailingSwipeAction(for: feedItem.id) {
                    case .markAsRead:
                        Button {
                            withAnimation {
                                model.perform(action: .markAsRead, on: feedItem.id)
                            }
                        } label: {
                            Label("Mark as read", systemImage: "envelope.open.fill")
                                .labelStyle(.iconOnly)
                        }
                        .tint(.green)
                    case .markAsUnread:
                        Button {
                            withAnimation {
                                model.perform(action: .markAsUnread, on: feedItem.id)
                            }
                        } label: {
                            Label("Mark as unread", systemImage: "envelope.fill")
                                .labelStyle(.iconOnly)
                        }
                        .tint(.blue)
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .refreshable {
            model.refresh()
        }
        .navigationTitle(model.navigationTitle)
        .navigationDestination(
            unwrapping: $model.destination,
            case: /CategoryFeedViewModel.Destination.article
        ) { $articleVM in
            ArticleView(model: articleVM)
        }
        .toolbar {
            Picker(model.filter.rawValue, selection: $model.filter) {
                ForEach(CategoryFeedViewModel.FilterOption.allCases, id: \.self) { Text($0.rawValue) }
            }
        }
        .searchable(text: $model.searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct CategoryFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CategoryFeedView(
                model: CategoryFeedViewModel(
                    rssClient: .mock,
                    storageClient: .empty,
                    category: .mock
                )
            )
        }
    }
}

// MARK: - Helpers
extension Date {
    func timePassed() -> String {
        let currentTime = Date()
        let seconds = currentTime.timeIntervalSince1970 - self.timeIntervalSince1970
        if seconds < 60 {
            let seconds = Int(seconds)
            return "\(seconds) second\(seconds == 1 ? "" : "s") ago"
        } else if seconds / 60 < 60 {
            let minutes = Int(seconds / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if seconds / 3600 < 24 {
            let hours = Int(seconds / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if seconds / (3600 * 24) < 365 {
            let days = Int(seconds / (3600 * 24))
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else {
            let years = Int(seconds / (3600 * 24 * 365))
            return "\(years) year\(years == 1 ? "" : "s") ago"
        }
    }
}
