//
//  GPX.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/11/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import Foundation

class GPX {
    fileprivate let file:File?
    
    init(fileName: String = "Location Data for \(Date().toShortStyleString())") {
        let fileName = fileName + ".gpx"
        file = File(fileName: fileName, in: .documentDirectory)

        file?.writeToNewlineAtEnd(content: "<?xml version=\"1.0\"?>")
        file?.writeToNewlineAtEnd(content: "<gpx version=\"1.1\" creator=\"Ethan Kreloff\">")
        file?.writeToNewlineAtEnd(content: "<metadata>\n<name>\(fileName)</name>\n<desc>Created using GPX Creator</desc>\n<author>Ethan Kreloff</author>\n<time>\(Date().toXSDDateTime())</time>\n</metadata>")
        file?.writeToNewlineAtEnd(content: "</gpx>")
    }
}

