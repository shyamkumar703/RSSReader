//
//  FeedItemView.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftUI

struct FeedItemView: View {
    @EnvironmentObject var session: SessionManager
    @State var feedItem: FeedEntry
    @StateObject var viewModel = ViewModel()
    
    let category: Category?
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            // Star label here probably!!
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
                
                Text(feedItem.feed.title)
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.75))
            }
        }
        .swipeActions {
            // No current way to star with the API
            
//            if feedItem.starred {
//                Button {
//                    // mark as unstarred
//                    feedItem.starred = false
//                    Task {
//                        await viewModel.shouldStar(false, item: feedItem, with: dependencies)
//                    }
//                } label: {
//                    Label("Unstar", systemImage: "star.slash.fill")
//                        .labelStyle(.iconOnly)
//                }
//                .tint(.red)
//            } else {
//                Button {
//                    // mark as starred (w/ API
//                    feedItem.starred = true
//                    Task {
//                        await viewModel.shouldStar(true, item: feedItem, with: dependencies)
//                    }
//                } label: {
//                    Label("Star", systemImage: "star.fill")
//                        .labelStyle(.iconOnly)
//                }
//                .tint(.yellow)
//            }
            
            if feedItem.status == .read {
                Button {
                    // mark as unread (w/ API)
                    feedItem.status = .unread
                    Task {
                        await viewModel.markAs(status: .unread, item: feedItem, with: session, category: category)
                    }
                } label: {
                    Label("Mark as unread", systemImage: "envelope.fill")
                        .labelStyle(.iconOnly)
                }
                .tint(.blue)
            } else {
                Button {
                    // mark as read (w/ API
                    feedItem.status = .read
                    Task {
                        await viewModel.markAs(status: .read, item: feedItem, with: session, category: category)
                    }
                } label: {
                    Label("Mark as read", systemImage: "envelope.open.fill")
                        .labelStyle(.iconOnly)
                }
                .tint(.green)
            }
        }
    }
}

extension FeedItemView {
    @MainActor class ViewModel: ObservableObject {
        func markAs(status: FeedEntry.Status, item: FeedEntry, with session: SessionManager, category: Category?) async {
            _ = await session.markAs(status: status, item: item, category: category)
        }
    }
}
