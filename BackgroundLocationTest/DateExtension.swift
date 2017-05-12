//
//  DateExtension.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/11/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import Foundation

//public extension Date {

//}

public extension DateFormatter {
    static var xsdDateTime:DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    static var shortStyle:DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    static var localMediumTimeStyle:DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter
    }
}
