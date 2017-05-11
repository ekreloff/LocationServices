//
//  GPX.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/11/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import Foundation

class GPX {
//    let fileName:String
    fileprivate let file:File?
    
    init(fileName: String = "Location Data for \(Date().toShortStyleString())") {
        
        file = File(fileName: fileName, in: .documentDirectory)
        print("")
        
//        self.fileName = fileName
//        writeToFileEnd(content: "<?xml version=\"1.0\"?>", fileName: self.fileName)
//        writeToFileEnd(content: "<gpx version=\"1.1\" creator=\"Ethan Kreloff\">", fileName: self.fileName)
//        writeToFileEnd(content: "<metadata><name>\(self.fileName)</name><desc>Created using GPX Creator</desc><author>Ethan Kreloff</author><time>\(Date().toXSDDateTime())</time></metadata>", fileName: self.fileName)
//        writeToFileEnd(content: "</gpx>", fileName: self.fileName)
    }
}

