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
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        LocationServices.shared.initialize()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        Log.shared.logToFileAndDebugger( "------------------ RESIGN ACTIVE ------------------")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Log.shared.logToFileAndDebugger( "------------------ ENTER BACKGROUND ------------------")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Log.shared.logToFileAndDebugger("------------------ ENTERED FOREGROUND ------------------")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Log.shared.logToFileAndDebugger( "------------------ BECOME ACTIVE ------------------")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Log.shared.logToFileAndDebugger( "------------------ WILL TERMINATE ------------------")
    }
}

