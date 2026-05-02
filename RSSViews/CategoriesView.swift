//
//  CategoriesView.swift
//  RSSViews
//
//  Created by Shyam Kumar on 6/11/23.
//

import Combine
import IdentifiedCollections
import RSSClient
import SwiftUI
import SwiftUINavigation

public class CategoriesViewModel: ObservableObject {
    var rssClient: RSSClient
    var storageClient: StorageClient
    
    @Published
    var categories = IdentifiedArrayOf<RSSCategory>()
    
    @Published
    var destination: Destination? = nil {
        didSet {
            if oldValue != nil && destination == nil {
                self.refresh()
            }
            self.bind()
        }
    }
    
    // MARK: - Cancellables
    var rssClientCancellable: AnyCancellable?
    
    public init(rssClient: RSSClient, storageClient: StorageClient, destination: Destination? = nil) {
        self.rssClient = rssClient
        self.storageClient = storageClient
        self.destination = destination
        self.refresh()

        self.bind()
    }

    private static func sortByUnread(_ lhs: RSSCategory, _ rhs: RSSCategory) -> Bool {
        guard let lhsUnread = lhs.unreadCount,
              let rhsUnread = rhs.unreadCount else { return true }
        return lhsUnread > rhsUnread
    }
    
    func markAsReadTapped(id: Int) {
        categories[id: id]?.unreadCount = 0
        rssClient.markCategoryAsRead(id)
        storageClient.markCategoryAsRead(categoryId: id)
    }
    
    func categoryTapped(category: RSSCategory) {
        self.destination = .feedView(
            CategoryFeedViewModel(
                rssClient: rssClient,
                storageClient: storageClient,
                category: category
            )
        )
    }
    
    func refresh() {
        // Show whatever's on disk first (may include BG sync's writes) so the
        // UI reflects the latest known state immediately, then hit the network.
        let cached = storageClient.getAllCategories().elements.sorted(by: Self.sortByUnread).unique()
        self.categories = IdentifiedArray(uniqueElements: cached)

        self.rssClientCancellable = rssClient.categories()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] categories in
                    let sortedCategories = categories.sorted(by: Self.sortByUnread)
                    self?.categories = IdentifiedArray(uniqueElements: sortedCategories.unique())
                    self?.storageClient.updateCategories(categories)
                }
            )
    }
    
    public enum Destination {
        case feedView(CategoryFeedViewModel)
    }
    
    private func bind() {
        guard let destination else { return }
        switch destination {
        case .feedView(let feedViewModel):
            feedViewModel.onArticleMarkedAsRead = { [weak self] categoryId in
                guard let self,
                      let categoryId,
                      let category = categories[id: categoryId],
                      let unreadCount = category.unreadCount else { return }
                
                categories[id: categoryId]?.unreadCount = max(unreadCount - 1, 0)
            }
            
            feedViewModel.onArticleMarkedAsUnread = { [weak self] categoryId in
                guard let self,
                      let categoryId,
                      let category = categories[id: categoryId],
                      let unreadCount = category.unreadCount else { return }
                
                categories[id: categoryId]?.unreadCount = unreadCount + 1
            }
        }
    }
}

public struct CategoriesView: View {
    @ObservedObject var model: CategoriesViewModel
    @Environment(\.refresh) var refresh
    @Environment(\.scenePhase) private var scenePhase
    @State private var wasInBackground = false

    public init(model: CategoriesViewModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(model.categories) { category in
                    HStack(alignment: .center, spacing: 16) {
                        if let first = category.title.first {
                            Text(String(first).capitalized)
                                .frame(width: 32, height: 32)
                                .foregroundColor(.white)
                                .font(.headline)
                                .background(colorFor(char: first))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Text(category.title.capitalized)
                        
                        Spacer()
                        
                        if let unreadCount = category.unreadCount,
                           unreadCount > 0 {
                            Text(String(unreadCount))
                                .foregroundColor(Color.secondary)
                        }
                        
                        Image(systemName: "chevron.forward")
                              .font(Font.system(.footnote).weight(.bold))
                              .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    .padding(8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.model.categoryTapped(category: category)
                    }
                    .contextMenu {
                        Button() {
                            model.markAsReadTapped(id: category.id)
                        } label: {
                            Label("Mark all as read", systemImage: "envelope.open")
                        }
                    }
                }
            }
            .refreshable {
                model.refresh()
            }
            .navigationTitle("Categories")
            .navigationDestination(
                unwrapping: self.$model.destination,
                case: /CategoriesViewModel.Destination.feedView
            ) { $model in
                CategoryFeedView(model: model)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                wasInBackground = true
            } else if newPhase == .active && wasInBackground {
                wasInBackground = false
                model.refresh()
            }
        }
    }
    
    func colorFor(char: Character) -> Color {
        switch char {
        case "A"..<"G":
            return .blue
        case "G"..<"M":
            return .mint
        case "M"..<"S":
            return .indigo
        default:
            return .pink
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView(
            model: CategoriesViewModel(
                rssClient: .mock,
                storageClient: .empty
            )
        )
    }
}
