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
    //    static public let defaultManager:LocationManager = LocationManager()
    fileprivate static let timerInterval:TimeInterval = 30
    fileprivate var locationManager = CLLocationManager()
    fileprivate var locationUpdateTimer:Timer?
    //    fileprivate var backgroundTimer:Timer?
    fileprivate var cycleCount = 0
    fileprivate var postInterval:TimeInterval = 120
    fileprivate var backgroundTaskIdentifier = UIBackgroundTaskInvalid
    public var mostRecentLocation:CLLocation?
    
    fileprivate let desiredAccuracy:CLLocationAccuracy = 11.0
    fileprivate let distanceFilter:CLLocationDistance = kCLDistanceFilterNone
    
    //    static fileprivate var locationManagerSingleton:() = {
    //        DispatchQueue.main.async {
    //            defaultManager.locationManager = CLLocationManager()
    //            if let locationManager = defaultManager.locationManager {
    //                locationManager.delegate = defaultManager
    //                locationManager.desiredAccuracy = kCLLocationAccuracyBest
    //                locationManager.activityType = .fitness
    //                locationManager.distanceFilter = kCLDistanceFilterNone
    //                locationManager.requestAlwaysAuthorization()
    //
    //                DispatchQueue.main.async {
    //                    defaultManager.foregroundTimer = Timer(fireAt: Date(), interval: foregroundTimerInterval, target: self, selector: #selector(defaultManager.requestLocation), userInfo: nil, repeats: true)
    //                    defaultManager.foregroundTimer?.fire()
    //                }
    //            }
    //        }
    //    }()
    
    //    class public func initializeLocationManager() {
    //        let _ = locationManagerSingleton
    //    }
    //
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = CLLocationDistanceMax
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        //        locationManager.stopUpdatingLocation()
        locationManager.delegate = self
        
        startForegroundTimer()
        
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startForegroundTimer() {
        guard locationUpdateTimer == nil else {
            return
        }
        
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: LocationManager.timerInterval, target: self, selector: #selector(switchToHighLocationAccuracy), userInfo: nil, repeats: true)
    }
    
    func stopForegroundTimer() {
        guard locationUpdateTimer != nil else {
            return
        }
        
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }
    
    //    func startBackgroundTimer() {
    //        guard backgroundTimer == nil else {
    //            return
    //        }
    //
    //        backgroundTimer = Timer.scheduledTimer(timeInterval: LocationManager.timerInterval, target: self, selector: #selector(switchToHighLocationAccuracy), userInfo: nil, repeats: true)
    //    }
    //
    //    func stopBackgroundTimer() {
    //        guard backgroundTimer != nil else {
    //            return
    //        }
    //
    //        backgroundTimer?.invalidate()
    //        backgroundTimer = nil
    //    }
    
    func switchToHighLocationAccuracy() {
        let intervalRatio = Int(postInterval/LocationManager.timerInterval)
        if cycleCount < intervalRatio {
            cycleCount += 1
        } else {
            if let coordinate = mostRecentLocation?.coordinate, let timestamp = mostRecentLocation?.timestamp, let accuracy = mostRecentLocation?.horizontalAccuracy {
                let dateformatter = DateFormatter()
                dateformatter.dateStyle = .none
                dateformatter.timeStyle = .medium
                dateformatter.timeZone = NSTimeZone.local
                //            print("<\(coordinate.latitude), \(coordinate.longitude)> recieved at \(dateformatter.string(from: timestamp)) with accuracy \(accuracy)" )
                print("POSTED   <\(coordinate.latitude), \(coordinate.longitude)> at \(dateformatter.string(from: timestamp)), accuracy: \(accuracy)")
                writeToFile(content: "POSTED   <\(coordinate.latitude), \(coordinate.longitude)> at \(dateformatter.string(from: timestamp)), accuracy: \(accuracy)")
            }
            
            cycleCount = 0
            mostRecentLocation = nil
        }
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .none
        dateformatter.timeStyle = .medium
        dateformatter.timeZone = NSTimeZone.local
        
        print("Cycle \(cycleCount) Start -------------------- \(dateformatter.string(from: Date()))")
        writeToFile(content: "Cycle \(cycleCount) Start -------------------- \(dateformatter.string(from: Date()))")
        
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter
        locationManager.requestLocation()
        //        locationManager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate, let timestamp = locations.first?.timestamp, let accuracy = locations.first?.horizontalAccuracy {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .none
            dateformatter.timeStyle = .medium
            dateformatter.timeZone = NSTimeZone.local
            print("RECIEVED <\(coordinate.latitude), \(coordinate.longitude)> at \(dateformatter.string(from: timestamp)), accuracy: \(accuracy)")
            writeToFile(content: "RECIEVED <\(coordinate.latitude), \(coordinate.longitude)> at \(dateformatter.string(from: timestamp)), accuracy: \(accuracy)")
        }
        
        for location in locations {
            if let mostRecentLocation = mostRecentLocation {
                if location.horizontalAccuracy <= mostRecentLocation.horizontalAccuracy {
                    self.mostRecentLocation = location
                    
                    if let coordinate = self.mostRecentLocation?.coordinate, let timestamp = self.mostRecentLocation?.timestamp, let accuracy = self.mostRecentLocation?.horizontalAccuracy {
                        let dateformatter = DateFormatter()
                        dateformatter.dateStyle = .none
                        dateformatter.timeStyle = .medium
                        dateformatter.timeZone = NSTimeZone.local
                        print("CHANGED  <\(coordinate.latitude), \(coordinate.longitude)> at \(dateformatter.string(from: timestamp)), accuracy: \(accuracy)")
                        writeToFile(content: "CHANGED  <\(coordinate.latitude), \(coordinate.longitude)> at \(dateformatter.string(from: timestamp)), accuracy: \(accuracy)")
                    }
                }
            } else if location.horizontalAccuracy >= 0 {
                mostRecentLocation = location
                
                if let coordinate = self.mostRecentLocation?.coordinate, let timestamp = self.mostRecentLocation?.timestamp, let accuracy = self.mostRecentLocation?.horizontalAccuracy {
                    let dateformatter = DateFormatter()
                    dateformatter.dateStyle = .none
                    dateformatter.timeStyle = .medium
                    dateformatter.timeZone = NSTimeZone.local
                    print("RESET    <\(coordinate.latitude), \(coordinate.longitude)> at \(dateformatter.string(from: timestamp)), accuracy: \(accuracy)")
                    writeToFile(content: "RESET    <\(coordinate.latitude), \(coordinate.longitude)> at \(dateformatter.string(from: timestamp)), accuracy: \(accuracy)")
                }
            }
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = CLLocationDistanceMax
        
        //        if UIApplication.shared.applicationState == .background {
        //            stopForegroundTimer()
        //            startForegroundTimer()
        //        }
        
        
        
        
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("FAILED   ------------------------------------")
        writeToFile(content: "FAILED   ------------------------------------")
    }
    
    //    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
    //        print("deferred update")
    //        deferring = false
    //    }
    //
    //
    func appLaunched() {
        print("------------------ APP LAUNCHED ------------------")
        writeToFile(content: "------------------ APP LAUNCHED ------------------")
    }
    
    func appEnteredForeground() {
        print("------------------ ENTERED FOREGROUND ------------------")
        writeToFile(content: "------------------ ENTERED FOREGROUND ------------------")
        
        locationManager.stopMonitoringSignificantLocationChanges()
        startForegroundTimer()
    }
    
    func appWillResignActive() {
        print("------------------ RESIGN ACTIVE ------------------")
        writeToFile(content: "------------------ RESIGN ACTIVE ------------------")
        
        
        //        locationManager.stopUpdatingLocation()
        //        locationManager.pausesLocationUpdatesAutomatically = false
        //        locationManager.startUpdatingLocation()
        
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
        }
        
        locationManager.startMonitoringSignificantLocationChanges()
        
        //        startBackgroundTimer()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appLaunched), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
}

public func writeToFile(content: String, fileName: String = "log.txt") {
    let contentWithNewLine = content+"\n"
    let filePath = NSHomeDirectory() + "/Documents/" + fileName
    let fileHandle = FileHandle(forWritingAtPath: filePath)
    if (fileHandle != nil) {
        fileHandle?.seekToEndOfFile()
        fileHandle?.write(contentWithNewLine.data(using: .utf8)!)
    } else {
        do {
            try contentWithNewLine.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Error while creating \(filePath)")
        }
    }
}

