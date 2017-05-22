//
//  LocationServices.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/22/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import CoreLocation
import UIKit

class LocationServices: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let postFrequency: TimeInterval = 60.0
    
    
    private var postLocationForegroundTimer: Timer?
    private var postLocationBackgroundTimer: Timer?
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    private var mostRecentLocation:CLLocation?

    static let shared = LocationServices()
    fileprivate override init() {
        super.init()
        
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
        
        addNotifications()
        startUpdatingLocation()
    }
    
    deinit {
        removeNotifications()
    }
    
    public func initialize() {
        let _ = LocationServices.shared
        startUpdatingLocation()
    }
    
    public func requestAlwaysAuthorizationIfNeeded() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                manager.requestAlwaysAuthorization()
            case .denied, .restricted:
                Log.shared.logToFileAndDebugger("Location services denied or restricted.")
            case .authorizedWhenInUse:
                Log.shared.logToFileAndDebugger("Location services only when in use.")
            case .authorizedAlways:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            guard location.timestamp > Date(timeIntervalSinceNow: -120.0) else {
                Log.shared.logToFileAndDebugger("location too old \(DateFormatter.localMediumTimeStyle.string(from: Date()))")
                continue
            }
            
            if let mostRecentLocation = mostRecentLocation {
                if mostRecentLocation.timestamp > Date(timeIntervalSinceNow: -30.0) {
                    if location.horizontalAccuracy <= mostRecentLocation.horizontalAccuracy {
                        //                    if location.timestamp <= mostRecentLocation.timestamp {
                        self.mostRecentLocation = location
                        //                    }
                    }
                } else {
                    self.mostRecentLocation = nil
                }
            } else if location.horizontalAccuracy >= 0 {
                mostRecentLocation = location
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.shared.logToFileAndDebugger("Location did fail")
    }
    
    func startUpdatingLocation() {
        manager.stopUpdatingLocation()
        manager.startUpdatingLocation()
        startForegroundTimer()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        stopBackgroundTimer()
        stopForegroundTimer()
    }
    
    func startForegroundTimer() {
        var timeRemaining:TimeInterval = 5.0
        if let timer = postLocationBackgroundTimer {
            timeRemaining = timer.fireDate.timeIntervalSinceNow
        }
        
        stopBackgroundTimer()
        
        if postLocationForegroundTimer == nil {
            postLocationForegroundTimer = Timer(fireAt: Date(timeIntervalSinceNow: timeRemaining), interval: postFrequency, target: self, selector: #selector(sendLocation), userInfo: nil, repeats: true)
            postLocationForegroundTimer?.tolerance = 1.0
            RunLoop.current.add(postLocationForegroundTimer!, forMode: .defaultRunLoopMode)
        }
    }
    
    func stopForegroundTimer() {
        if let timer = postLocationForegroundTimer {
            timer.invalidate()
            postLocationForegroundTimer = nil
        }
    }
    
    func startBackgroundTimer() {
        var timeRemaining:TimeInterval = 0.0
        if let timer = postLocationForegroundTimer {
            timeRemaining = timer.fireDate.timeIntervalSinceNow
        }
        
        stopForegroundTimer()
        
        if bgTask == UIBackgroundTaskInvalid {
            bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                UIApplication.shared.endBackgroundTask(self.bgTask)
            })
        }
        
        if postLocationBackgroundTimer == nil {
            postLocationBackgroundTimer = Timer(fireAt: Date(timeIntervalSinceNow: timeRemaining), interval: postFrequency, target: self, selector: #selector(sendLocation), userInfo: nil, repeats: true)
            postLocationBackgroundTimer?.tolerance = 1.0
            RunLoop.current.add(postLocationBackgroundTimer!, forMode: .defaultRunLoopMode)
        }
    }
    
    func stopBackgroundTimer() {
        guard bgTask != UIBackgroundTaskInvalid else {
            return
        }
        
        UIApplication.shared.endBackgroundTask(bgTask)
        bgTask = UIBackgroundTaskInvalid

        if let timer = postLocationBackgroundTimer {
            timer.invalidate()
            postLocationBackgroundTimer = nil
        }
    }
    
    func sendLocation() {
        Log.shared.logToFileAndDebugger("NEW MANAGER POST UPDATE ====== \(mostRecentLocation ?? CLLocation()) at \(DateFormatter.localMediumTimeStyle.string(from: Date()))")
    }
    
    private func addNotifications() {
        removeNotifications()
        
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidEnterBackground),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(applicationDidBecomeActive),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationDidEnterBackground() {
        startBackgroundTimer()
    }
    
    func applicationDidBecomeActive() {
        startForegroundTimer()
    }
}
