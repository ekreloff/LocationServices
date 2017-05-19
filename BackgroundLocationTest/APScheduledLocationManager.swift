//
//  Created by Aleksandrs Proskurins
//
//  License
//  Copyright © 2016 Aleksandrs Proskurins
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit
import CoreLocation


public protocol APScheduledLocationManagerDelegate {
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didFailWithError error: Error)
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didUpdateLocations location: CLLocation)
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}


public class APScheduledLocationManager: NSObject, CLLocationManagerDelegate {
    
    private let MaxBGTime: TimeInterval = 170
    private let MinBGTime: TimeInterval = 2
    private let MinAcceptableLocationAccuracy: CLLocationAccuracy = 5
    private let WaitForLocationsTime: TimeInterval = 5
    
    private let delegate: APScheduledLocationManagerDelegate
    private let manager = CLLocationManager()
    
    private var isManagerRunning = false
    private var checkLocationTimer: Timer?
    private var waitTimer: Timer?
//    private var postTimer: Timer?
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    private var lastLocations = [CLLocation]()
    private var mostRecentLocation:CLLocation?
    private var cycleCount = 0

    
    public private(set) var acceptableLocationAccuracy: CLLocationAccuracy = 1000000
    public private(set) var checkLocationInterval: TimeInterval = 25
//    public private(set) var postLocationInterval: TimeInterval = 120
    public private(set) var isRunning = false
    
    public init(delegate: APScheduledLocationManagerDelegate) {
        
        self.delegate = delegate
        
        super.init()
        
//        configureLocationManager()
    }
    
    public func configureLocationManager(accuracy: CLLocationAccuracy?, distance: CLLocationDistance?) {
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = accuracy ?? 30.0
        manager.distanceFilter = distance ?? kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
        
//        startPostLocationTimer()
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
    
    public func startUpdatingLocation(interval: TimeInterval, acceptableLocationAccuracy: CLLocationAccuracy = 1000000) {
        if isRunning {
            stopUpdatingLocation()
        }
        
        checkLocationInterval = interval > MaxBGTime ? MaxBGTime : interval
        checkLocationInterval = interval < MinBGTime ? MinBGTime : interval
        
        self.acceptableLocationAccuracy = max(acceptableLocationAccuracy, MinAcceptableLocationAccuracy)
        
        isRunning = true
        
        addNotifications()
        startLocationManager()
    }
    
    public func stopUpdatingLocation() {
        isRunning = false
        
        stopWaitTimer()
        stopLocationManager()
        stopBackgroundTask()
        stopCheckLocationTimer()
        removeNotifications()
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
    
    private func startLocationManager() {
        isManagerRunning = true
        manager.startUpdatingLocation()
    }
    
    private func stopLocationManager() {
        isManagerRunning = false
        manager.stopUpdatingLocation()
    }
    
    @objc func applicationDidEnterBackground() {
        stopBackgroundTask()
        startBackgroundTask()
    }
    
    @objc func applicationDidBecomeActive() {
        stopBackgroundTask()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate.scheduledLocationManager(self, didChangeAuthorization: status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate.scheduledLocationManager(self, didFailWithError: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isManagerRunning, locations.count > 0 else {
            return
        }
        
        lastLocations = locations
        
        for location in lastLocations {
            guard location.timestamp > Date(timeIntervalSinceNow: -120.0) else {
                continue
            }
            
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

        
        if waitTimer == nil {
            startWaitTimer()
        }
    }
    
    private func startCheckLocationTimer() {
        stopCheckLocationTimer()
        checkLocationTimer = Timer.scheduledTimer(timeInterval: checkLocationInterval, target: self, selector: #selector(checkLocationTimerEvent), userInfo: nil, repeats: false)
    }
    
    private func stopCheckLocationTimer() {
        if let timer = checkLocationTimer {
            timer.invalidate()
            checkLocationTimer = nil
        }
    }
    
    func checkLocationTimerEvent() {
        
        stopCheckLocationTimer()
        
        startLocationManager()
        
        // starting from iOS 7 and above stop background task with delay, otherwise location service won't start
        self.perform(#selector(stopAndResetBgTaskIfNeeded), with: nil, afterDelay: 1)
    }
    
//    private func startPostLocationTimer() {
//        stopPostLocationTimer()
//        postTimer = Timer.scheduledTimer(timeInterval: postLocationInterval, target: self, selector: #selector(postLocationTimerEvent), userInfo: nil, repeats: true)
//    }
//    
//    private func stopPostLocationTimer() {
//        if let timer = postTimer {
//            timer.invalidate()
//            postTimer = nil
//        }
//    }
//    
//    func postLocationTimerEvent() {
//        if let location = mostRecentLocation {
//            logRecentLocationEventToFileAndDebugger(title: "POSTED")
//            delegate.scheduledLocationManager(self, didUpdateLocations: location)
//        }
//    }
//    
    private func startWaitTimer() {
        stopWaitTimer()
        
        waitTimer = Timer.scheduledTimer(timeInterval: WaitForLocationsTime, target: self, selector: #selector(waitTimerEvent), userInfo: nil, repeats: false)
    }
    
    private func stopWaitTimer() {
        
        if let timer = waitTimer {
            
            timer.invalidate()
            waitTimer=nil
        }
    }
    
    func waitTimerEvent() {
        
        stopWaitTimer()
        
        if acceptableLocationAccuracyRetrieved() {
            
            startBackgroundTask()
            startCheckLocationTimer()
            stopLocationManager()
            
            let intervalRatio = 4//Int(postInterval/timerInterval)
        
            if cycleCount < intervalRatio {
                cycleCount += 1
            } else {
                if let location = mostRecentLocation {
                    logRecentLocationEventToFileAndDebugger(title: "POSTED")
                    delegate.scheduledLocationManager(self, didUpdateLocations: location)
                }
                
                cycleCount = 1
                mostRecentLocation = nil
            }
            
            Log.shared.logToFileAndDebugger("Cycle \(cycleCount) Start -------------------- \(DateFormatter.localMediumTimeStyle.string(from: Date()))")
        }else{
            startWaitTimer()
        }
    }
    
    private func acceptableLocationAccuracyRetrieved() -> Bool {
        if let location = mostRecentLocation{
            return location.horizontalAccuracy <= acceptableLocationAccuracy ? true : false
        } else {
            return false
        }
    }
    
    func stopAndResetBgTaskIfNeeded()  {
        if isManagerRunning {
            stopBackgroundTask()
        }else{
            stopBackgroundTask()
            startBackgroundTask()
        }
    }
    
    private func startBackgroundTask() {
        let state = UIApplication.shared.applicationState
        
        if ((state == .background || state == .inactive) && bgTask == UIBackgroundTaskInvalid) {
            
            bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                
                self.checkLocationTimerEvent()
            })
        }
    }
    
    @objc private func stopBackgroundTask() {
        guard bgTask != UIBackgroundTaskInvalid else { return }
        
        UIApplication.shared.endBackgroundTask(bgTask)
        bgTask = UIBackgroundTaskInvalid
    }
    
    func logRecentLocationEventToFileAndDebugger(title: String) {
        if let coordinate = self.mostRecentLocation?.coordinate, let timestamp = self.mostRecentLocation?.timestamp, let accuracy = self.mostRecentLocation?.horizontalAccuracy {
            Log.shared.logToFileAndDebugger("\(title) <\(coordinate.latitude), \(coordinate.longitude)> at \(DateFormatter.localMediumTimeStyle.string(from: title == "POSTED" ? Date() : timestamp)), accuracy: \(accuracy)")
        }
    }
    
    func logRecievedLocationEventToFileAndDebugger(location: CLLocation, title: String = "RECIEVED") {
        Log.shared.logToFileAndDebugger("\(title) <\(location.coordinate.latitude), \(location.coordinate.longitude)> at \(DateFormatter.localMediumTimeStyle.string(from: location.timestamp)), accuracy: \(location.horizontalAccuracy)")
    }

}
