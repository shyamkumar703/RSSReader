//
//  RSSApp.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import RSSClientLive
import RSSViews
import SwiftUI

@main
struct RSSApp: App {
    @StateObject var session = SessionManager(dependencies: Dependencies())
    
    var body: some Scene {
        WindowGroup {
            RSSViews.CategoriesView(model: .init(rssClient: .live, storageClient: .live))
        }
    }
}
