//
//  RSSApp.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftUI

@main
struct RSSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var session = SessionManager(dependencies: Dependencies())
    
    var body: some Scene {
        WindowGroup {
            CategoriesView(path: [Category.example])
                .environmentObject(session)
        }
    }
}
