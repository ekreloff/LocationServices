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
    
    var locationManager = LocationManager()
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
            startStopButton.setTitle("Finish GPX", for: .normal)
            
            for textField in stackViewFields {
                textField.isHidden = true
            }
            
            activityIndicator.startAnimating()
            
            if let fileName = fileNameTextField.text {
                gpx = GPX(fileName: fileName)
            } else {
                gpx = GPX()
            }
        } else {
            startStopButton.setTitle("Start New GPX", for: .normal)
            
            for textField in stackViewFields {
                textField.isHidden = false
            }
            
            activityIndicator.stopAnimating()
            gpx?.finishGPX()
            gpx = nil
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    
}

