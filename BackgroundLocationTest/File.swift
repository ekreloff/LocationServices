//
//  File.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/11/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import Foundation

class File {
    let filePath:URL
    let fileHandle:FileHandle
    
    init?(fileName: String, in directory: FileManager.SearchPathDirectory, domainMask: FileManager.SearchPathDomainMask = .userDomainMask) {
        do {
            filePath = try FileManager.default.url(for: directory, in: domainMask, appropriateFor: nil, create: true).appendingPathComponent(fileName.withEscapedSpaces())
            
            if let fileHandle = try? FileHandle(forUpdating: filePath) {
                self.fileHandle = fileHandle
            } else {
                try "".write(to: filePath, atomically: true, encoding: .utf8)
                self.fileHandle = try FileHandle(forWritingTo: filePath)
            }
        } catch {
            return nil
        }
    }
}
