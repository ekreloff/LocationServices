//
//  AppDelegate.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/8/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Log.shared.logToFileAndDebugger("------------------ APP LAUNCHED ------------------")
        
        if let _ = launchOptions?[UIApplicationLaunchOptionsKey.location] {
            Log.shared.logToFileAndDebugger("----------------- APP RELAUNCHED FOR LOCATION UPDATE -----------------")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        Log.shared.logToFileAndDebugger( "------------------ RESIGN ACTIVE ------------------")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Log.shared.logToFileAndDebugger("------------------ ENTERED FOREGROUND ------------------")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

