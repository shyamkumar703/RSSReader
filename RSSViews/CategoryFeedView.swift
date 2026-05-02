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
    var isPartial = false

    @Published
    var isLoadingMore = false

    private var currentOffset = 0
    private var totalCount = 0

    var hasMore: Bool { feed.count < totalCount }

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
    var filter: FeedFilter = .unread {
        didSet {
            guard oldValue != filter else { return }
            refresh()
        }
    }

    @Published
    var searchText: String = ""


    var navigationTitle: String {
        category?.title ?? "All"
    }
    
    // MARK: - Cancellables
    var rssClientCancellable: AnyCancellable?
    var loadMoreCancellable: AnyCancellable?
    var searchCancellable: AnyCancellable?
    
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
        self.refresh()

        self.bind()

        self.searchCancellable = $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in self?.refresh() }
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
        case .all: return feed
        case .unread: return feed.filter { $0.status == .unread }
        case .starred: return feed.filter { $0.starred }
        }
    }
    
    func refresh() {
        currentOffset = 0
        loadMoreCancellable = nil

        // Show whatever's on disk immediately (may include BG sync's writes).
        // Only meaningful when the filter/search match what was cached
        // (storage caches by category id only). Stale-but-fast > spinner.
        if let cached = storageClient.getFeedFor(categoryId: category?.id ?? 0) {
            self.feed = IdentifiedArray(uniqueElements: cached.entries.unique())
            self.totalCount = cached.total
            self.currentOffset = cached.entries.count
        }

        rssClientCancellable = rssClient.feedFor(category?.id, 0, filter, searchText)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] response in
                    guard let self else { return }
                    self.feed = IdentifiedArray(uniqueElements: response.entries.unique())
                    self.totalCount = response.total
                    self.currentOffset = response.entries.count
                    self.isPartial = false
                    var copy = response
                    self.storageClient.updateFeed(for: self.category?.id ?? 0, feedResponse: &copy)
                }
            )
    }

    func loadMoreIfNeeded() {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true
        loadMoreCancellable = rssClient.feedFor(category?.id, currentOffset, filter, searchText)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingMore = false
                    if case .failure = completion { self?.isPartial = true }
                },
                receiveValue: { [weak self] response in
                    guard let self else { return }
                    let existingIds = self.feed.ids
                    let toAppend = response.entries.filter { !existingIds.contains($0.id) }
                    self.feed.append(contentsOf: toAppend)
                    self.currentOffset += response.entries.count
                    self.totalCount = response.total
                    self.isPartial = false
                }
            )
    }
}

public struct CategoryFeedView: View {
    @ObservedObject var model: CategoryFeedViewModel
    @Environment(\.refresh) var refresh
    @Environment(\.scenePhase) private var scenePhase
    @State private var wasInBackground = false

    public init(model: CategoryFeedViewModel) {
        self.model = model
    }
    
    public var body: some View {
        if model.isPartial {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Some articles couldn't be loaded. Pull to refresh.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
        }

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
                .onAppear {
                    if let idx = model.feed.index(id: feedItem.id),
                       idx >= model.feed.count - 5 {
                        model.loadMoreIfNeeded()
                    }
                }
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
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Filter", selection: $model.filter) {
                        ForEach(FeedFilter.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    ZStack {
                        Text(FeedFilter.allCases.map(\.rawValue).max(by: { $0.count < $1.count }) ?? "")
                            .hidden()
                        Text(model.filter.rawValue)
                    }
                }
            }
        }
        .searchable(text: $model.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                wasInBackground = true
            } else if newPhase == .active && wasInBackground {
                wasInBackground = false
                model.refresh()
            }
        }
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
