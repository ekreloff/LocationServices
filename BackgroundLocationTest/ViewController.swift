//
//  ViewController.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/8/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

class ViewController: UIViewController, APScheduledLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }

    func scheduledLocationManager(_ manager: APScheduledLocationManager, didUpdateLocations location: CLLocation) {
        Log.shared.logToDebugger("\(location.timestamp)")
        
        var description = gpxDescription
        let additionalInfo = "Actual: \(location.horizontalAccuracy)\nBackground?: \(UIApplication.shared.applicationState == .background)\n\(DateFormatter.localMediumTimeStyle.string(from: Date()))\nBattery: \( UIDevice.current.batteryLevel)"
        description += additionalInfo
        gpx?.addCoordinate(location: location.coordinate, description: description)

    }

    func scheduledLocationManager(_ manager: APScheduledLocationManager, didFailWithError error: Error) {
        
    }

//    fileprivate var locationManager:LocationManager? = nil
    fileprivate var manager: APScheduledLocationManager!
    fileprivate var gpx:GPX? = nil
    fileprivate var tracking = false
    fileprivate var gpxDescription = ""

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var getLocationFrequencyTextField: UITextField!
    @IBOutlet weak var postLocationFrequencyTextField: UITextField!
    @IBOutlet weak var desiredAccuracyTextField: UITextField!
    @IBOutlet weak var distanceFilterTextField: UITextField!
    
    @IBOutlet var stackViewFields: [UITextField]!
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBAction func startStopButtonAction() {
        if !tracking {
            tracking = true
    
            for textField in stackViewFields {
                textField.isHidden = true
            }
            
            activityIndicator.startAnimating()
            startStopButton.setTitle("Finish GPX", for: .normal)
            setGPXFile()
            setLocationManager()
            addObservers()
        } else {
            tracking = false
            
            for textField in stackViewFields {
                textField.isHidden = false
            }
            
            activityIndicator.stopAnimating()
            startStopButton.setTitle("Start New GPX", for: .normal)
            gpx?.finishGPX()
//            gpx = nil //race condition wirting and clearing
//            locationManager = nil
            manager.stopUpdatingLocation()
            removeObservers()
            
            
            sendEmail()
            
        }
        
    }
    
    func sendEmail() {
        if let gpx = gpx {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients(["ekreloff@10-4.com"])
            composeVC.setSubject("\(gpx.fileName)")
            //        composeVC.setMessageBody("Hello this is my message body!", isHTML: false)
            if let data = try? Data(contentsOf: gpx.path) {
                composeVC.addAttachmentData(data, mimeType: "application/xml", fileName: gpx.fileName)
                self.present(composeVC, animated: true, completion: nil)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        switch result {
//        case .cancelled, .failed:
//            break
//            case .sent,
//        default:
//            <#code#>
//        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for textField in stackViewFields {
            textField.delegate = self
        }
    }
    
    deinit {
        removeObservers()
    }
    
    func setGPXFile() {
        if let fileName = fileNameTextField.text, !fileName.isEmpty {
            gpx = GPX(fileName: fileName)
        } else {
            gpx = GPX()
        }
    }

    func setLocationManager() {
        var getFrequency:TimeInterval? = nil
        var postFrequency:TimeInterval? = nil
        var desiredAccuracy:CLLocationAccuracy? = nil
        var distanceFilter:CLLocationDistance? = nil
        
        func setGPXDescription() {
            gpxDescription = "Get location frequency: \(getFrequency ?? 30.0)\nPost location frequency: \(postFrequency ?? 120.0)\nDistance filter: \(distanceFilter ?? kCLDistanceFilterNone)\nDesired accuracy: \(desiredAccuracy ?? 15.0), "
        }
        
        if let value = getLocationFrequencyTextField.text, !value.isEmpty {
            getFrequency = TimeInterval(value)
        }
        
        if let value = postLocationFrequencyTextField.text, !value.isEmpty {
            postFrequency = TimeInterval(value)
        }
        
        if let value = desiredAccuracyTextField.text, !value.isEmpty {
            desiredAccuracy = CLLocationAccuracy(value)
        }
        
        if let value = distanceFilterTextField.text, !value.isEmpty {
            distanceFilter = CLLocationDistance(value)
        }
        
        setGPXDescription()
        manager = APScheduledLocationManager(delegate: self)
        manager.configureLocationManager(accuracy: desiredAccuracy, distance: distanceFilter)
        manager.requestAlwaysAuthorizationIfNeeded()
        manager.startUpdatingLocation(interval: 30.0, acceptableLocationAccuracy: 1000.0)
//        locationManager = LocationManager(getInterval: getFrequency, postInterval: postFrequency, accuracy: desiredAccuracy, distance: distanceFilter)`
    }
    
//    func recieveLocation(_ notification: Notification) {
//        guard let location = notification.userInfo?["Location"] as? CLLocation else {
//            return
//        }
//        
//        var description = gpxDescription
//        let additionalInfo = "Actual: \(location.horizontalAccuracy)\nBackground?: \(UIApplication.shared.applicationState == .background)\n\(DateFormatter.localMediumTimeStyle.string(from: Date()))\nBattery: \( UIDevice.current.batteryLevel)"
//        description += additionalInfo
//        gpx?.addCoordinate(location: location.coordinate, description: description)
////        gpx?.addComment(additionalInfo)
//    }
    
    func addObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(recieveLocation(_:)), name: Notification.Name.Custom.LocationUpdated, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

