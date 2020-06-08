//
//  File.swift
//  Krapao Tracker
//
//  Created by Book Lailert on 27/11/18.
//  Copyright © 2018 Book Lailert. All rights reserved.
//

import Foundation

extension Int {
    func calculateDistance() -> NSNumber {
        var calibration = 0
        var minimumVal = 0
        var logVal = Float(0)
        calibration = UserDefaults().integer(forKey: "DistanceCalibration")
        minimumVal = UserDefaults().integer(forKey: "MinimumCalibration")
        logVal = UserDefaults().float(forKey: "LogCalibration")
        if calibration == 0 {
            calibration = 9
        }
        if minimumVal == 0 {
            minimumVal = 55
        }
        if logVal == Float(0) {
            logVal = Float(2)
        }
        let absoluteRssi:Double = Double(self)*Double(integerLiteral: (-1))
        var distance:Double = absoluteRssi - Double(minimumVal)
        let calibrateVal:Double = Double(calibration)/Double(100)
        distance = distance*calibrateVal
        distance = pow(distance, Double(logVal))
        return NSNumber(floatLiteral: Double(round(distance*2)/2))
    }
}

extension Collection where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { return reduce(0, +) }
}

extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0 : Double(Int(total)) / Double(count)
    }
}

extension Collection where Element: BinaryFloatingPoint {
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

