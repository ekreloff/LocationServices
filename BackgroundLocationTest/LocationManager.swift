//
//  LocationManager.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/8/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import CoreLocation
import UIKit

public extension Notification.Name {
    enum Custom {
        static let LocationUpdated = Notification.Name("Location Updated")
    }
}

public final class LocationManager: NSObject, CLLocationManagerDelegate {
    fileprivate let locationManager = CLLocationManager()
    
    fileprivate let desiredAccuracy:CLLocationAccuracy
    fileprivate let distanceFilter:CLLocationDistance
    fileprivate let timerInterval:TimeInterval
    fileprivate let postInterval:TimeInterval
    
    fileprivate var cycleCount = 0
    fileprivate var locationUpdateTimer:TimerEnhanced?
    fileprivate var backgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    public var mostRecentLocation:CLLocation?
    
    init(getInterval:TimeInterval = 30, postInterval:TimeInterval = 120, accuracy:CLLocationAccuracy = 15.0, distance:CLLocationDistance = kCLDistanceFilterNone) {
        self.timerInterval = getInterval
        self.postInterval = postInterval
        self.desiredAccuracy = accuracy
        self.distanceFilter = distance
        
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = CLLocationDistanceMax
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        locationUpdateTimer?.start(interval: timerInterval, target: self, selector: #selector(switchToHighLocationAccuracy), userInfo: nil, repeats: true)
        
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        locationUpdateTimer?.stop()
    }
    
    func switchToHighLocationAccuracy() {
        let intervalRatio = Int(postInterval/timerInterval)
        if cycleCount < intervalRatio {
            cycleCount += 1
        } else {
            if let location = mostRecentLocation, let timestamp = mostRecentLocation?.timestamp, let accuracy = mostRecentLocation?.horizontalAccuracy {
                logToFileAndDebuggerForLocationManager(title: "POSTED")
                NotificationCenter.default.post(name: Notification.Name.Custom.LocationUpdated, object: nil, userInfo: ["Location":location])
            }
            
            cycleCount = 1
            mostRecentLocation = nil
        }
        
        Log.shared.logToFileAndDebugger("Cycle \(cycleCount) Start -------------------- \(DateFormatter.localMediumTimeStyle.string(from: Date()))")
        
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter
        locationManager.requestLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logToFileAndDebuggerForLocationManager(title: "RECIEVED")
        
        for location in locations {
            if let mostRecentLocation = mostRecentLocation {
                if location.horizontalAccuracy <= mostRecentLocation.horizontalAccuracy {
                    self.mostRecentLocation = location
                    logToFileAndDebuggerForLocationManager(title: "CHANGED")
                }
            } else if location.horizontalAccuracy >= 0 {
                mostRecentLocation = location
                logToFileAndDebuggerForLocationManager(title: "RESET")
            }
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = CLLocationDistanceMax
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.shared.logToFileAndDebugger("FAILED   ------------------------------------")
    }
    
    func appLaunched() {
        Log.shared.logToFileAndDebugger("------------------ APP LAUNCHED ------------------")
    }
    
    func appEnteredForeground() {
        Log.shared.logToFileAndDebugger("------------------ ENTERED FOREGROUND ------------------")
        locationManager.stopMonitoringSignificantLocationChanges()
        locationUpdateTimer?.restartIfNotRunning()
    }
    
    func appWillResignActive() {
        Log.shared.logToFileAndDebugger( "------------------ RESIGN ACTIVE ------------------")

        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
        }
        
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appLaunched), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    func logToFileAndDebuggerForLocationManager(title: String) {
        if let coordinate = self.mostRecentLocation?.coordinate, let timestamp = self.mostRecentLocation?.timestamp, let accuracy = self.mostRecentLocation?.horizontalAccuracy {
            Log.shared.logToFileAndDebugger("\(title) <\(coordinate.latitude), \(coordinate.longitude)> at \(DateFormatter.localMediumTimeStyle.string(from: timestamp)), accuracy: \(accuracy)")
        }
    }
}
