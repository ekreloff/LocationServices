//
//  GPX.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/11/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import CoreLocation

class GPX {
    fileprivate let file:File?
    fileprivate let timeStampFormatter = DateFormatter.xsdDateTime
    
    init(fileName: String = "Location Data for \(DateFormatter.shortStyle.string(from: Date()))") {
        
        
        
        let fileName = fileName + ".gpx"
        file = File(fileName: fileName, in: .documentDirectory)

        file?.writeToBeginning(content: "<?xml version=\"1.0\"?>")
        file?.writeToNewlineAtEnd(content: "<gpx version=\"1.1\" creator=\"Ethan Kreloff\">")
        file?.writeToNewlineAtEnd(content: "<metadata>\n<name>\(fileName)</name>\n<desc>Created using GPX Creator</desc>\n<author>Ethan Kreloff</author>\n<time>\(timeStampFormatter.string(from: Date()))</time>\n</metadata>")
//        file?.writeToNewlineAtEnd(content: "</gpx>")
        

        
        
    }
    
    func addCoordinate(location: CLLocationCoordinate2D, at time: Date = Date(), name: String? = nil, description: String? = nil) {
        var coordinateEntry = "<wpt lat=\"\(location.latitude)\" lon=\"\(location.longitude)\">"
        coordinateEntry.append("\n<time>\(timeStampFormatter.string(from: time))</time>")
        
        if let name = name {
            coordinateEntry.append("\n<name>\(name)</name>")
        }
        
        if let description = description {
            coordinateEntry.append("\n<desc>\(description)</desc>")
        }
        
        coordinateEntry.append("</wpt>")
        file?.writeToNewlineAtEnd(content: coordinateEntry)
    }
    
    func finishGPX() {
        file?.writeToNewlineAtEnd(content: "</gpx>")
        file?.closeFile()
    }
    
    deinit {
        finishGPX()
    }
}

