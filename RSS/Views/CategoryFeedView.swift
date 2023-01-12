//
//  CategoryFeedView.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftUI

struct CategoryFeedView: View {
    @EnvironmentObject var dependencies: Dependencies
    @StateObject var viewModel = ViewModel()
    let feedCategory: Category?
    var firstChar: Character {
        feedCategory?.title.first ?? "A"
    }
    
    var body: some View {
        List {
            ForEach(viewModel.feed) { feedItem in
                NavigationLink {
                    EntryView(feedEntry: feedItem)
                } label: {
                    HStack(alignment: .top) {
                        // Star label here probably!!
                        
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
                }
            }
        }
        .navigationTitle(feedCategory?.title ?? "All")
        .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                Text(String(firstChar).capitalized)
//                    .frame(width: 24, height: 24)
//                    .foregroundColor(.white)
//                    .font(.subheadline)
//                    .background(colorFor(char: firstChar))
//                    .clipShape(RoundedRectangle(cornerRadius: 6))
//            }
        .task {
            await viewModel.loadFeed(for: feedCategory, with: dependencies)
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
