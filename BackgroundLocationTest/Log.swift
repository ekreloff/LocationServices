//
//  Log.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/12/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import Foundation

public class Log {
    static let shared = Log()
    fileprivate let logFile:File?
    
    fileprivate init() {
        logFile = File(fileName: "Log File", in: .documentDirectory)
        logFile?.writeToBeginning("Log Created \(Date())")
    }
    
    func logToFile(_ content: String) {
        logFile?.writeToNewlineAtEnd(content)
    }
    
    func logToDebugger(_ content: String) {
        print(content)
    }
    
    func logToFileAndDebugger(_ content: String) {
        logToFile(content)
        logToDebugger(content)
    }
}
