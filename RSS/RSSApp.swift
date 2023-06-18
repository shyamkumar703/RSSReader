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
    var body: some Scene {
        WindowGroup {
            RSSViews.CategoriesView(model: .init(rssClient: .live, storageClient: .live))
        }
    }
}
