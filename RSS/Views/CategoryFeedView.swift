//
//  CategoryFeedView.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftUI

struct CategoryFeedView: View {
    enum FilterOptions: String, CaseIterable {
        case unread = "Unread"
        case starred = "Starred"
        case all = "All"
    }
    
    @EnvironmentObject var session: SessionManager
    @StateObject var viewModel = ViewModel()
    @State var currentFilter = FilterOptions.unread
    @Environment(\.refresh) var refresh
    let feedCategory: Category?
    
    var firstChar: Character {
        feedCategory?.title.first ?? "A"
    }
    
    var filteredFeed: [FeedEntry] {
        switch currentFilter {
        case .all: return session.feedFor(category: feedCategory)
        case .unread: return session.feedFor(category: feedCategory).filter({ $0.status == .unread })
        case .starred: return session.feedFor(category: feedCategory).filter({ $0.starred })
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading && filteredFeed.isEmpty {
                ProgressView()
                    .padding()
            } else if filteredFeed.isEmpty {
                Text("Nothing here yet")
                    .foregroundColor(.secondary)
            } else {
                VStack {
                    List {
                        ForEach(filteredFeed) { feedItem in
                            NavigationLink {
                                if session.dependencies.localStorage.readShouldUseNativeHTMLViewer() {
                                    EntryView(feedEntry: feedItem, category: feedCategory)
                                        .environmentObject(session)
                                } else {
                                    NavigationView {
                                        WebViewSafari(url: URL(string: feedItem.url)!)
                                        
                                    }
                                    .task { await session.markAs(status: .read, item: feedItem, category: feedCategory) }
                                    .navigationBarTitleDisplayMode(.inline)
                                }
                            } label: {
                                FeedItemView(feedItem: feedItem, category: feedCategory)
                                    .environmentObject(session)
                                    .onAppear {
                                        if let index = filteredFeed.firstIndex(of: feedItem) {
                                            if index > filteredFeed.count - 6 {
                                                Task {
                                                    await viewModel.loadItems(for: feedCategory, before: filteredFeed[filteredFeed.count - 1].date, with: session)
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    
                    if viewModel.isLoading && !filteredFeed.isEmpty {
                        ProgressView()
                            .padding()
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadFeed(for: feedCategory, with: session)
        }
        .navigationTitle(feedCategory?.title ?? "All")
        .task {
            await viewModel.loadFeed(for: feedCategory, with: session)
        }
        .toolbar {
            Picker(currentFilter.rawValue, selection: $currentFilter) {
                ForEach(FilterOptions.allCases, id: \.self) { Text($0.rawValue) }
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

struct CategoryFeedView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryFeedView(feedCategory: nil)
            .environmentObject(SessionManager(dependencies: Dependencies()))
    }
}
