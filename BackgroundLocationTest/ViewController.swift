//
//  ViewController.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/8/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    fileprivate var locationManager:LocationManager? = nil
    fileprivate var gpx:GPX? = nil
    fileprivate var tracking = false

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
            locationManager = nil
            removeObservers()
        }
        
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
        if let value = getLocationFrequencyTextField.text, !value.isEmpty {
            getFrequency = TimeInterval(value)
        }
        
        var postFrequency:TimeInterval? = nil
        if let value = postLocationFrequencyTextField.text, !value.isEmpty {
            postFrequency = TimeInterval(value)
        }
        
        var desiredAccuracy:CLLocationAccuracy? = nil
        if let value = desiredAccuracyTextField.text, !value.isEmpty {
            desiredAccuracy = CLLocationAccuracy(value)
        }
        
        var distanceFilter:CLLocationDistance? = nil
        if let value = distanceFilterTextField.text, !value.isEmpty {
            distanceFilter = CLLocationDistance(value)
        }
        
        locationManager = LocationManager(getInterval: getFrequency, postInterval: postFrequency, accuracy: desiredAccuracy, distance: distanceFilter)
    }
    
    func recieveLocation(_ notification: Notification) {
        guard let location = notification.userInfo?["Location"] as? CLLocation else {
            return
        }
        
        gpx?.addCoordinate(location: location.coordinate, description: "Put variables herer")
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(recieveLocation(_:)), name: Notification.Name.Custom.LocationUpdated, object: nil)
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

