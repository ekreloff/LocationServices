//
//  LocationManager.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/8/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import CoreLocation
import UIKit

public final class LocationManager: NSObject, CLLocationManagerDelegate {
    fileprivate let locationManager = CLLocationManager()
    
    fileprivate let desiredAccuracy:CLLocationAccuracy
    fileprivate let distanceFilter:CLLocationDistance
    fileprivate let timerInterval:TimeInterval
    fileprivate let postInterval:TimeInterval
    
    fileprivate var cycleCount = 0
//    fileprivate var locationUpdateTimer:TimerEnhanced? = TimerEnhanced()
    fileprivate var locationUpdateTimer:Timer?
    fileprivate var backgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    public var mostRecentLocation:CLLocation?
    
    init(getInterval:TimeInterval? = 30.0, postInterval:TimeInterval? = 120.0, accuracy:CLLocationAccuracy? = 15.0, distance:CLLocationDistance? = kCLDistanceFilterNone) {
        self.timerInterval = getInterval ?? 30.0
        self.postInterval = postInterval ?? 120.0
        self.desiredAccuracy = accuracy ?? 15.0
        self.distanceFilter = distance ?? kCLDistanceFilterNone
        
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = CLLocationDistanceMax
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
//        weak var weakSelf:LocationManager? = self
//        locationUpdateTimer?.start(interval: timerInterval, target: weakSelf!, selector: #selector(switchToHighLocationAccuracy), userInfo: nil, repeats: true)
        startTimer()
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
//        locationUpdateTimer?.stop()
        stopTimer()
    }
    
    func startTimer() {
        guard locationUpdateTimer == nil else {
            return
        }
        
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(switchToHighLocationAccuracy), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        guard locationUpdateTimer != nil else {
            return
        }
        
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }
    
    func switchToHighLocationAccuracy() {
        let intervalRatio = Int(postInterval/timerInterval)
        if cycleCount < intervalRatio {
            cycleCount += 1
        } else {
            if let location = mostRecentLocation {
                logRecentLocationEventToFileAndDebugger(title: "POSTED")
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
        for location in locations {
            logRecievedLocationEventToFileAndDebugger(location: location)
            if let mostRecentLocation = mostRecentLocation {
                if location.horizontalAccuracy <= mostRecentLocation.horizontalAccuracy {
                    self.mostRecentLocation = location
                    logRecentLocationEventToFileAndDebugger(title: "CHANGED")
                }
            } else if location.horizontalAccuracy >= 0 {
                mostRecentLocation = location
                logRecentLocationEventToFileAndDebugger(title: "RESET")
            }
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = CLLocationDistanceMax
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.shared.logToFileAndDebugger("FAILED   ------------------------------------")
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    func appEnteredForeground() {
        locationManager.stopMonitoringSignificantLocationChanges()
//        locationUpdateTimer?.restartIfNotRunning()
        startTimer()
    }
    
    func appWillResignActive() {
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
        }
        
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func logRecentLocationEventToFileAndDebugger(title: String) {
        if let coordinate = self.mostRecentLocation?.coordinate, let timestamp = self.mostRecentLocation?.timestamp, let accuracy = self.mostRecentLocation?.horizontalAccuracy {
            Log.shared.logToFileAndDebugger("\(title) <\(coordinate.latitude), \(coordinate.longitude)> at \(DateFormatter.localMediumTimeStyle.string(from: timestamp)), accuracy: \(accuracy)")
        }
    }
    
    func logRecievedLocationEventToFileAndDebugger(location: CLLocation, title: String = "RECIEVED") {
        Log.shared.logToFileAndDebugger("\(title) <\(location.coordinate.latitude), \(location.coordinate.longitude)> at \(DateFormatter.localMediumTimeStyle.string(from: location.timestamp)), accuracy: \(location.horizontalAccuracy)")
    }
}
