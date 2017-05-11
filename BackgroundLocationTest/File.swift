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
    
    func writeToNewlineAtEnd(content: String) {
        let content = "\n" + content
        fileHandle.seekToEndOfFile()
        
        if let data = content.data(using: .utf8) {
            fileHandle.write(data)
        }
    }
    

}




public func writeToFileEnd(content: String, fileName: String = "log.txt") {
    let contentWithNewLine = content+"\n"
    let filePath = NSHomeDirectory() + "/Documents/" + fileName
    let fileHandle = FileHandle(forWritingAtPath: filePath)
    if (fileHandle != nil) {
        fileHandle?.seekToEndOfFile()
        fileHandle?.write(contentWithNewLine.data(using: .utf8)!)
    } else {
        do {
            try contentWithNewLine.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Error while creating \(filePath)")
        }
    }
}
