//
//  EntryView.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftRichString
import SwiftUI

struct EntryView: View {
    let feedEntry: FeedEntry
    @StateObject private var viewModel = ViewModel()
    @State private var isShowingWebSheet = false
    @EnvironmentObject var session: SessionManager
    
    let category: Category?
    
    var body: some View {
        if let attrString = viewModel.generateAttributedText(for: feedEntry) {
            ScrollView {
                VStack(spacing: 8) {
                    Text(feedEntry.title)
                        .font(.headline)
                        .frame(alignment: .center)
                        .padding()
                    
                    Text(attrString)
                        .lineSpacing(4)
                        .frame(alignment: .leading)
                        .padding()
                }
            }
//                .navigationTitle(feedEntry.title)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    isShowingWebSheet = true
                } label: {
                    Image(systemName: "safari.fill")
                }
            }
            .sheet(isPresented: $isShowingWebSheet) {
                WebView(url: URL(string: feedEntry.url)!)
                    .padding(0)
            }
            .onAppear {
                Task {
                    await viewModel.markAsRead(for: feedEntry, with: session, category: category)
                }
            }
        } else {
            Text("Whoops")
                .padding()
        }
    }
}

extension EntryView {
    @MainActor class ViewModel: ObservableObject {
        func generateAttributedText(for entry: FeedEntry) -> SwiftUI.AttributedString? {
            // Create style
            let normal = Style {
                $0.font = SystemFonts.Helvetica_Light.font(size: 15)
            }
            
            let bold = Style {
                $0.font = SystemFonts.Helvetica_Bold.font(size: 15)
            }
            
            let italic = normal.byAdding {
                $0.traitVariants = .italic
            }
            
            let code = Style {
                $0.font = SystemFonts.Menlo_Regular.font(size: 15)
            }
            
            let group = StyleXML(
                base: normal,
                ["bold": bold, "italic": italic, "code": code]
            )
            
            let attrString = entry.content.set(style: group)
            return try? SwiftUI.AttributedString(attrString, including: \.uiKit)
        }
        
        func markAsRead(for entry: FeedEntry, with session: SessionManager, category: Category?) async {
            _ = await session.markAs(status: .read, item: entry, category: category)
        }
    }
}
