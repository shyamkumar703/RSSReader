//
//  AppDelegate.swift
//  RSS
//
//  Created by Shyam Kumar on 3/29/23.
//

import QueryBuilderSwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        QueryBuilderSDK.setComparableTypes(to: [FeedEntry.Status.self, Feed.self])
        return true
    }
}
