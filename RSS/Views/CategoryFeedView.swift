//
//  CategoryFeedView.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import QueryBuilderSwiftUI
import SwiftUI

struct CategoryFeedView: View {
    
    @EnvironmentObject var session: SessionManager
    @StateObject var viewModel = ViewModel()
    @Environment(\.refresh) var refresh
    let feedCategory: Category?
    
    var firstChar: Character {
        feedCategory?.title.first ?? "A"
    }
    
    @State private var fullFeed: [FeedEntry] = []
    @State private var filteredFeed: [FeedEntry]?
    
    var currentFeed: [FeedEntry] {
        filteredFeed ?? fullFeed
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading && currentFeed.isEmpty {
                ProgressView()
                    .padding()
            } else if currentFeed.isEmpty {
                Text("Nothing here yet")
                    .foregroundColor(.secondary)
            } else {
                VStack {
                    List {
                        ForEach(currentFeed) { feedItem in
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
                                        if let index = currentFeed.firstIndex(of: feedItem) {
                                            if index > currentFeed.count - 6 && currentFeed.count >= 20 {
                                                Task {
                                                    let beforeDate = currentFeed[currentFeed.count - 1].date
                                                    await viewModel.loadItems(for: feedCategory, before: beforeDate, with: session)
                                                    fullFeed = session.feedFor(category: feedCategory)
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    
                    if viewModel.isLoading && !currentFeed.isEmpty {
                        // FIXME: bg in light mode is weird
                        ProgressView()
                            .padding()
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadFeed(for: feedCategory, with: session)
            fullFeed = session.feedFor(category: feedCategory)
        }
        .navigationTitle(feedCategory?.title ?? "All")
        .task {
            await viewModel.loadFeed(for: feedCategory, with: session)
            fullFeed = session.feedFor(category: feedCategory)
        }
        .toolbar {
//            Picker(currentFilter.rawValue, selection: $currentFilter) {
//                ForEach(FilterOptions.allCases, id: \.self) { Text($0.rawValue) }
//            }
            QueryFilterView(allItems: $fullFeed, filteredItems: $filteredFeed)
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
