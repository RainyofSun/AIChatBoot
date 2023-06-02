//
//  AppDelegate.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Facebook统计初始化
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        initializationBuriedPointStatistics()
        initializationPushTool(application)
        return true
    }

    // Open URI-scheme for iOS 9 and above
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // appsFlyer统计
        LRAppsFlyerStatistics.shared.handleOpenUrl(url, options: options)
        // facebook统计
        ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
        return true
    }
    
    // Open URI-scheme for iOS 8 and below
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        LRAppsFlyerStatistics.shared.handleOpenUrl(url, sourceApplication: sourceApplication, annotation: annotation)
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // Open Univerasal Links
    // For Swift version < 4.2 replace function signature with the commented out code
    // func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool { // this line for Swift < 4.2
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        LRAppsFlyerStatistics.shared.openUniverasalLinks(userActivity: userActivity)
        return true
    }
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return true
    }

}

private extension AppDelegate {
    /// 三方统计初始化
    func initializationBuriedPointStatistics() {
        let _ = LRAppsFlyerStatistics.shared
        let _ = LRFirebaseStatistics.shared
        let _ = LRUMengStatistics.shared
    }
    
    /// 三方推送初始化
    func initializationPushTool(_ application: UIApplication) {
        
    }
}
