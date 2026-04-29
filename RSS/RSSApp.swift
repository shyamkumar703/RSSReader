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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            RSSViews.CategoriesView(model: .init(rssClient: .live, storageClient: .live))
        }
        .onChange(of: scenePhase) { _, phase in
            print("[scenePhase] new phase=\(phase)")
            if phase == .background { BackgroundSync.schedule() }
        }
    }
}
