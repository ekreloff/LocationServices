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
            filePath = try FileManager.default.url(for: directory, in: domainMask, appropriateFor: nil, create: true).appendingPathComponent(fileName.fileNameFormattedForFileSystem())
            
            if let fileHandle = try? FileHandle(forWritingTo: filePath) {
                self.fileHandle = fileHandle
            } else {
                try "".write(to: filePath, atomically: true, encoding: .utf8)
                self.fileHandle = try FileHandle(forWritingTo: filePath)
            }
        } catch {
            return nil
        }
    }
    
    func writeToBeginning(_ content: String) {
        fileHandle.seek(toFileOffset: 0)
        
        if let data = content.data(using: .utf8) {
            fileHandle.write(data)
        }
    }

    func writeToNewlineAtEnd(_ content: String) {
        let content = "\n" + content
        fileHandle.seekToEndOfFile()
        
        if let data = content.data(using: .utf8) {
            fileHandle.write(data)
        }
    }
    
    func closeFile() {
        fileHandle.closeFile()
    }
    
    deinit {
        closeFile()
    }
}




