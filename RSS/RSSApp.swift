//
//  RSSApp.swift
//  RSS
//
//  Created by Shyam Kumar on 1/11/23.
//

import SwiftUI

@main
struct RSSApp: App {
    @StateObject var dependencies = Dependencies()
    
    var body: some Scene {
        WindowGroup {
            CategoriesView()
                .environmentObject(dependencies)
        }
    }
}
