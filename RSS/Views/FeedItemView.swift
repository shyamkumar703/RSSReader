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
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    var tertiaryTitleText: String {
        var startTitle = feedItem.feed.title
        if let readTime = feedItem.readingTime {
            startTitle += " · \(readTime) minute read"
        }
        return startTitle
    }
    
    var bottomTitleText: String? {
        dateFormatter.date(from: feedItem.publishedAt)?.timePassed()
    }
    
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
                
                Text(tertiaryTitleText)
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.75))
                
                if let bottomTitleText {
                    Text(bottomTitleText)
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.75))
                }
            }
        }
        .swipeActions {
            if feedItem.starred {
                Button {
                    // mark as unstarred
                    feedItem.starred = false
                    Task {
                        await viewModel.toggleStar(item: feedItem, in: category, with: session)
                    }
                } label: {
                    Label("Unstar", systemImage: "star.slash.fill")
                        .labelStyle(.iconOnly)
                }
                .tint(.red)
            } else {
                Button {
                    // mark as starred (w/ API
                    feedItem.starred = true
                    Task {
                        await viewModel.toggleStar(item: feedItem, in: category, with: session)
                    }
                } label: {
                    Label("Star", systemImage: "star.fill")
                        .labelStyle(.iconOnly)
                }
                .tint(.yellow)
            }
            
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
        
        func toggleStar(item: FeedEntry, in category: Category?, with session: SessionManager) async {
            await session.toggleStar(for: item, in: category)
        }
    }
}
