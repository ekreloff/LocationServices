//
//  StringExtension.swift
//  BackgroundLocationTest
//
//  Created by Ethan Kreloff on 5/11/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import Foundation

public extension String {
    func withEscapedSpaces() -> String{
        return self.replacingOccurrences(of: " ", with: "\\ ")
    }
}
