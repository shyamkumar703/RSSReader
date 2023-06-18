//
//  ArticleView.swift
//  RSSViews
//
//  Created by Shyam Kumar on 6/12/23.
//

import RSSClient
import SwiftUI
import SwiftUINavigation
import XCTestDynamicOverlay

public class ArticleViewModel: ObservableObject {
    @Published
    var feedEntry: FeedEntry
    
    @Published
    var destination: Destination?
    
    var rssClient: RSSClient
    
    public enum Destination {
        case webView(URL)
    }
    
    var onToggleStar: (Bool) -> Void = unimplemented("ArticleViewModel.onToggleStar")
    
    var contentURL: URL? {
        URL(string: feedEntry.url)
    }
    
    var articleTitle: String {
        feedEntry.title
    }
    
    public init(feedEntry: FeedEntry, rssClient: RSSClient, destination: Destination? = nil, onToggleStar: ((Bool) -> Void)? = nil) {
        self.feedEntry = feedEntry
        self.rssClient = rssClient
        self.destination = destination
        if let onToggleStar {
            self.onToggleStar = onToggleStar
        }
    }
    
    func showWebSheetTapped() {
        guard let url = URL(string: feedEntry.url) else { return }
        self.destination = .webView(url)
    }
    
    func toggleStarTapped() {
        feedEntry.starred.toggle()
        onToggleStar(feedEntry.starred)
        rssClient.toggleStar(feedEntry.id)
    }
}

public struct ArticleView: View {
    @ObservedObject var model: ArticleViewModel
    @Environment(\.dismiss) var dismiss
    
    public init(model: ArticleViewModel) {
        self.model = model
    }
    
    public var body: some View {
        ScrollView {
            RichText(html: model.feedEntry.content)
                .fontType(.system)
                .foregroundColor(light: Color.black, dark: Color.white)
                .imageRadius(12)
                .placeholder {
                    ProgressView()
                        .padding()
                }
                .padding()
                .frame(maxWidth: UIScreen.main.bounds.width)
        }
        .toolbar {
            HStack {
                if let contentURL = model.contentURL {
                    ShareLink(item: contentURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                
                Button {
                    model.showWebSheetTapped()
                } label: {
                    Image(systemName: "safari")
                }
                
                Button {
                    model.toggleStarTapped()
                } label: {
                    switch model.feedEntry.starred {
                    case true: Image(systemName: "star.fill")
                    case false: Image(systemName: "star")
                    }
                }
            }
        }
        .sheet(
            unwrapping: $model.destination,
            case: /ArticleViewModel.Destination.webView) { $url in
                NavigationView {
                    WebViewSafari(url: url)
                        .padding(0)
                        .navigationTitle(model.articleTitle)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            Button("Done") { dismiss() }
                        }
                }
        }
    }
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArticleView(model: ArticleViewModel(feedEntry: .unread(id: 1), rssClient: .mock))
        }
    }
}
