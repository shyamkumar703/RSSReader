//
//  AppDelegate.swift
//  RSS
//
//  Created by Shyam Kumar on 3/29/23.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("[AppDelegate] didFinishLaunching fired")
        BackgroundSync.register()
        return true
    }
}
