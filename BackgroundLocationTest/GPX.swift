//
//  GPX.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/11/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import Foundation

class GPX {
    
    init(filename: String = "Location Data for \(Date().toShortStyleString())") {
        writeToFile(content: "<?xml version=\"1.0\"?>", fileName: filename)
        writeToFile(content: "<gpx version=\"1.1\" creator=\"Ethan Kreloff\">", fileName: filename)
        writeToFile(content: "<metadata><>")
    }
}

extension Date {
    func toShortStyleString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    
}
