//
//  EntryView.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftUI

struct EntryView: View {
    let feedEntry: FeedEntry
    @StateObject private var viewModel = ViewModel()
    @State private var isShowingWebSheet = false
    @EnvironmentObject var session: SessionManager
    
    let category: Category?
    
    var body: some View {
        ScrollView {
            RichText(html: feedEntry.content)
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
            Button {
                isShowingWebSheet = true
            } label: {
                Image(systemName: "safari.fill")
            }
        }
        .sheet(isPresented: $isShowingWebSheet) {
            WebViewSafari(url: URL(string: feedEntry.url)!)
                .padding(0)
        }
        .onAppear {
            Task {
                await viewModel.markAsRead(for: feedEntry, with: session, category: category)
            }
        }
    }
}

extension EntryView {
    @MainActor class ViewModel: ObservableObject {
        func markAsRead(for entry: FeedEntry, with session: SessionManager, category: Category?) async {
            _ = await session.markAs(status: .read, item: entry, category: category)
        }
    }
}
