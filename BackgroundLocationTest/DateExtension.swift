//
//  DateExtension.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/11/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import Foundation

public extension Date {
    func toShortStyleString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    func toXSDDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
}
