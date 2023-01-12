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
    
    @EnvironmentObject var dependencies: Dependencies
    @StateObject var viewModel = ViewModel()
    @State var currentFilter = FilterOptions.unread
    @Environment(\.refresh) var refresh
    let feedCategory: Category?
    
    var firstChar: Character {
        feedCategory?.title.first ?? "A"
    }
    
    var filteredFeed: [FeedEntry] {
        switch currentFilter {
        case .all: return viewModel.feed
        case .unread: return viewModel.feed.filter({ $0.status == .unread })
        case .starred: return viewModel.feed.filter({ $0.starred })
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredFeed) { feedItem in
                NavigationLink {
                    EntryView(feedEntry: feedItem)
                        .environmentObject(dependencies)
                } label: {
                    FeedItemView(feedItem: feedItem)
                        .environmentObject(dependencies)
                }
            }
        }
        .refreshable {
            await viewModel.loadFeed(for: feedCategory, with: dependencies)
        }
        .navigationTitle(feedCategory?.title ?? "All")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadFeed(for: feedCategory, with: dependencies)
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
            .environmentObject(Dependencies())
    }
}